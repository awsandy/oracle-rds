alter table LINEITEM
    drop constraint LINEITEM_ORDERS_O_ORDERKEY_fk;

alter table LINEITEM
    drop constraint LINEITEM_PART_FK;

alter table LINEITEM
    drop constraint LINEITEM_SUPPLIER_FK;

alter table PARTSUPP
    drop constraint PARTSUPP_SUPP_S_SUPPKEY_fk;

alter table PARTSUPP
    drop constraint PARTSUPP_PART_fk;

alter table ORDERS
    drop constraint ORDERS_CUSTOMER_fk;

alter table CUSTOMER
    drop constraint CUSTOMER_NATION_fk;

alter table NATION
    drop constraint NATION_REGION_fk;

alter table CUSTOMER
    drop constraint CUSTOMER_pk;

alter table ORDERS
    drop constraint ORDER_pk;

alter table LINEITEM
    drop constraint LINEITEM_pk;

alter table NATION
    drop constraint NATION_pk;

alter table PART
    drop constraint PART_pk;

alter table PARTSUPP
    drop constraint PARTSUPP_pk;

alter table REGION
    drop constraint REGION_pk;

alter table SUPPLIER
    drop constraint SUPPLIER_pk;