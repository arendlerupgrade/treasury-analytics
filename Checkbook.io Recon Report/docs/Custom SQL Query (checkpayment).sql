-- Workbook: Checkbook.io Recon Report
-- Datasource: Custom SQL Query (checkpayment)
-- Query: Custom SQL Query

select
    c.create_date::date as create_date,
    c.target_account_id as loan_id,
    round(c.amount::float, 2) as checkbook_amount,
    round(k.amount::float, 2) as kyriba_amount,
    round(c.amount::float, 2) - round(k.amount::float, 2) as variance
from checkpayment.check_account_disbursement c
full outer join (
    select det.*
    from kyriba.kyriba_payment_file_entry pmt
    left join kyriba.kyriba_payment_entry_detail det
        on det.kyriba_payment_file_entry_id = pmt.id
    where from_id = 79
) k
    on c.create_date::date = k.process_date::date
    and round(c.amount::float, 2) = round(k.amount::float, 2)
where c.processor = 'CHECKBOOK_IO'
and c.status in ('PROCESSED', 'PENDING')
