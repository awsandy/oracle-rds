
-- Data Duplicate : Only run once

alter session force parallel DML &parallelclause;

alter session force parallel query &parallelclause;

 insert /*+ APPEND */
 into &inventories_target
 (
   PRODUCT_ID,
   WAREHOUSE_ID,
   QUANTITY_ON_HAND
 )
 select PRODUCT_ID,
   WAREHOUSE_ID,
   QUANTITY_ON_HAND
from inventories &whereclause;

commit;