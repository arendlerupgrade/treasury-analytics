-- Solution: CRB Collateral Reporting
-- Datasource: Custom SQL Query (core)
-- Query: Custom SQL Query1

SELECT "crb_collateral_hi_oid"."effective_date" AS "effective_date",
  "crb_collateral_hi_oid"."hi_oid" AS "hi_oid"
FROM "dw_fbo_analytics"."crb_collateral_hi_oid" "crb_collateral_hi_oid"
where effective_date <<= getdate()
