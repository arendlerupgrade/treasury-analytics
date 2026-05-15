-- Solution: CRB Collateral Reporting
-- Datasource: Custom SQL Query (core) (2)
-- Query: Custom SQL Query

select
  da.loan_id
, da.origination_date
, la.projected_purchase_date as purchase_date
, da.expected_first_month_payment::date
, da.principal_balance
, da.accrued_interest
, case when la.seasoner_investment_account_id = 5000006 then 'Y'
        else 'N'
  end as is_seasoned
, case when la.seasoner_investment_account_id is null then la.investment_account_id
        else la.seasoner_investment_account_id
  end as investor_id
, la.investment_account_id as allocation_investor_id
, case when sap.buyer_investment_account_id is not null then 'PURCHASED'
        else 'NO'
  end as LTHFS_sale_status
from core.report_daily_positions da
left join invmgt.select_asset_purchase sap on sap.loan_id=da.loan_id
left join invmgt.loan_allocation la on la.loan_id=da.loan_id
where 1 = 1
and da.product_type = 'PERSONAL_LOAN'
and da.investor_id in (5000005, 5000006)
UNION
--loans originated today
select
  la.loan_id
, la.create_date::date as origination_date
, la.projected_purchase_date as purchase_date
, dateadd(month,1,la.create_date::date)::date as expected_first_month_payment
, trunc(l.amount,0) as loan_amount
, la.investor_interim_interest as interim_interest
, case when la.seasoner_investment_account_id = 5000006 then 'Y'
        else 'N'
  end as is_seasoned
, case when la.seasoner_investment_account_id is null then la.investment_account_id
        else la.seasoner_investment_account_id
  end as investor_id
, la.investment_account_id as allocation_investor_id
, 'NO' as LTHFS_sale_status
from invmgt.loan_allocation la
left join invmgt.loan l on l.loan_id = la.loan_id
where 1 = 1
and la.create_date::date >>= CAST(getdate() AS DATE)
and la.loan_product_type = 'PERSONAL_LOAN'
and l.issuing_bank_id in (5000005)
order by origination_date DESC
