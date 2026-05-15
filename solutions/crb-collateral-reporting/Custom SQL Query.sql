-- Solution: CRB Collateral Reporting
-- Datasource: Custom SQL Query (core)
-- Query: Custom SQL Query

select 'CARD' as "PRODUCT_TYPE", 

-- 'ALL' as "SUB_CLASS",

case when pcl.is_core_expansion ='true' then 'NONCORE' 
                when ml.sub_policy_segment !='NONE' and ml.sub_policy_segment is not null then 'NONCORE' 
                when lps.segment = 'EXPANDED_POLICY' then 'NONCORE'
                when la.allocation_policy='SPECIAL' then 'NONCORE'
                when ml.sub_policy_segment ='NONE' or ml.sub_policy_segment is null then 'CORE' 
                end as "SUB_CLASS",

lps.processing_date::date as snapshot_date, subline_id as loan_id,
days_past_due as dpd,
case when coalesce(ap.master_line_account_number,-1) = -1 then 'No' else 'Yes' end as Early_pay,
''  as BRBFlag,

upper(lps.subline_status) as loan_subline_status, lps.loan_status_category, sum(lps.principal_balance) as sum_principal_balance, lps.investor_id, lps.line_closed_for_draws_date::date as sl_close_or_org_date, (lps.processing_date - lps.line_closed_for_draws_date::date) as num_of_days
from core.loan_position_snapshot_subline lps
left join lineservicing.auto_pay ap on lps.masterline_id = case when auto_pay_type IN ('EARLY_PAY')
AND status IN ('ACTIVE') then ap.master_line_account_number end
LEFT JOIN invmgt.master_line ml ON lps.masterline_id = ml.account_number
LEFT JOIN (SELECT DISTINCT loan_id, allocation_policy from invmgt.loan_allocation where loan_product_type = 'PERSONAL_CREDIT_LINE' and delete_date is null and allocation_policy='SPECIAL') la ON la.loan_id = lps.loan_id
LEFT JOIN (
    select distinct pcl.id as masterline_id,  pcloffer.is_core_expansion
    from loanreview.loan_in_review as pcl
    left join decisioning.application as app on app.loan_app_id = pcl.id
    left join decisioning.offer offer on app.selected_offer_id = offer.id
    left join decisioning.pcl_offer as pcloffer on offer.pcl_offer_id = pcloffer.id
    where pcloffer.is_core_expansion = 'true'
) as pcl on lps.masterline_id = pcl.masterline_id
where 1=1
and lps.investor_id in (
                5000002 --CRB Issuing Bank (we default all allocations to LTHFS)
                ,5000003 ----CRB Card Seasoner
                )
and lps.product_type = 'PERSONAL_CREDIT_LINE'
and (lps.processing_date::date = (getdate()-1)::date)
group by lps.processing_date, dpd, lps.subline_status, lps.subline_id,
lps.investor_id, lps.line_closed_for_draws_date::date, 
lps.loan_status_category, Early_pay, sub_policy_segment, 
lps.segment, pcl.masterline_id, la.allocation_policy,pcl.is_core_expansion
UNION ALL
--personal loan balances on CRB PL Seasoner

select 
case
when lps.investor_id in (5000044,5000045) then 'INDIRECT_AUTO_REFI'
when ia.product_sub_type = 'INDIRECT_AUTO' THEN 'INDIRECT_AUTO'
when lps.auto_secured_type = 'AUTO_REFINANCE' then 'AUTO_REFI'
when lps.investor_id in (5000048,5000047) then 'HOME_SECURED'
else 'PERSONAL_LOAN' end
as "PRODUCT_TYPE",
case when ia.product_sub_type = 'INDIRECT_AUTO' THEN 'ALL'
when is_auto_secured = 'Y' and ia.product_sub_type != 'INDIRECT_AUTO' or lps.investor_id in (5000044,5000045) then 'ALL'
when lps.investor_id in (5000048,5000047) then 'ALL'
when ia.product_sub_type = 'REGULAR' AND loan.investor_segment = 'NEAR_PRIME'  then 'NEAR_PRIME'
when ia.product_sub_type = 'REGULAR' AND loan.apr <<= .18 and loan.decisioning_primary_fico_score >>= 660 and loan.investor_segment <<>> 'NEAR_PRIME' then 'order_1'
else 'order_2' end as SUB_CLASS,
 lps.processing_date::date as snapshot_date, lps.loan_id,
days_past_due as dpd,
'No' as Early_pay,
case when lir_issuance_bank = 'BRB' then 'BRB' else '' end as BRBFlag,
 upper(lps.loan_status) as loan_subline_status, lps.loan_status_category, sum(lps.principal_balance) as sum_principal_balance, lps.investor_id, la.create_date::date as sl_close_or_org_date, (lps.processing_date::date - la.create_date::date) as num_of_days
from core.loan_position_snapshot lps
left join invmgt.loan_allocation la on la.loan_id = lps.loan_id
left join invmgt.investment_account ia on lps.investor_id = ia.id
left join invmgt.loan loan on loan.loan_id = lps.loan_id
where 1=1
and lps.investor_id in (
               5000005 --CRB Issuing Bank (must consider how loans are allocated to determine if LTHFS)
               ,5000006 --CRB PL Seasoner
               ,5000045 --auto refi
               ,5000048 --secured home
,5000044 --auto refi
               ,5000047 --secured home
                )
--and lps.product_type = 'PERSONAL_LOAN'
and lps.processing_date::date = (getdate()-1)::date 
and la.seasoner_investment_account_id in (5000006, 5000045, 5000048)
group by lps.processing_date::date, dpd, lps.loan_id, lps.loan_status, investor_id, lir_issuance_bank, lps.origination_date::date, lps.loan_status_category,la.create_date,auto_secured_type, ia.product_sub_type, SUB_CLASS


UNION ALL


--home improvement balances on CRB HI Seasoner
select 'HOME_IMPROVEMENT' as "PRODUCT_TYPE", 'ALL' as "SUB_CLASS", lpshi.snapshot_date::date as snapshot_date, lpshi.loan_id,
days_past_due as dpd,
'No' as Early_pay,
'' as BRBFlag,

 upper(lpshi.subline_status) as loan_subline_status, lpshi.loan_status_category, sum(lpshi.principal_balance) as sum_principal_balance, lpshi.investor_id, lpshi.origination_date::date as sl_close_or_org_date, (lpshi.snapshot_date::date - lpshi.origination_date::date) as num_of_days
from core.loan_position_snapshot_subline_hicl lpshi
where 1=1
and lpshi.investor_id in (
                7000002, --CRB Issuing Bank (we default all allocations to LTHFS)
                7000003 --CRB HI Seasoner
                )
and lpshi.product_type = 'HOME_IMPROVEMENT_CREDIT_LINE'
and (lpshi.snapshot_date::date = (getdate()-1)::date)
group by lpshi.snapshot_date::date,lpshi.loan_id, lpshi.loan_status_category, dpd, investor_id, lpshi.origination_date::date, lpshi.subline_status


UNION ALL


select 'CASH_ADVANCE' as "PRODUCT_TYPE", 'ALL' as "SUB_CLASS", lspca.processing_date::date as snapshot_date, lspca.loan_id,
days_past_due as dpd,
'No' as Early_pay,
'' as BRBFlag,

 upper(lspca.account_status) as loan_subline_status, case when account_status = 'CLOSED'  then 'paid_off'
when days_past_due = 0 then 'current'
when days_past_due >>= 120 then 'past_due_120'
when days_past_due >>= 90 then 'past_due_90'
when days_past_due >>= 60 then 'past_due_60'
when days_past_due >>= 30 then 'past_due_30'
when days_past_due >> 15 then 'past_due_16'
end as loan_status_category, sum(lspca.principal_balance) as sum_principal_balance, lspca.investor_id, lspca.origination_date::date as sl_close_or_org_date, (lspca.processing_date::date - lspca.origination_date::date) as num_of_days
from core.loan_position_snapshot_cadv lspca
left join invmgt.loan_allocation la on la.loan_id = lspca.loan_id
where 1=1
and lspca.investor_id in (
                5000032,
                5000031 
                )
and la.seasoner_investment_account_id = 5000032
and lspca.processing_date::date = (getdate()-1)::date 
group by lspca.processing_date::date, lspca.loan_id, loan_status_category, dpd, investor_id, lspca.origination_date::date, lspca.account_status
