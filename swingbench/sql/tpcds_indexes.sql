alter session force parallel ddl parallel &parallelism;

alter session force parallel query parallel &parallelism;


CREATE INDEX inventory_nuk ON inventory
  (
    inv_date_sk,
    inv_item_sk,
    inv_warehouse_sk
  )
  TABLESPACE &indextablespace;

