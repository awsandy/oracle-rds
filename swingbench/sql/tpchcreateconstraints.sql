alter table CUSTOMER
    add constraint CUSTOMER_pk
        primary key (C_CUSTKEY)
            RELY DISABLE NOVALIDATE;

alter table ORDERS
    add constraint ORDER_pk
        primary key (O_ORDERKEY)
            RELY DISABLE NOVALIDATE;

alter table LINEITEM
    add constraint LINEITEM_pk
        primary key (L_ORDERKEY, L_LINENUMBER)
            RELY DISABLE NOVALIDATE;

alter table NATION
    add constraint NATION_pk
        primary key (N_NATIONKEY)
            RELY DISABLE NOVALIDATE;

alter table PART
    add constraint PART_pk
        primary key (P_PARTKEY)
            RELY DISABLE NOVALIDATE;

alter table PARTSUPP
    add constraint PARTSUPP_pk
        primary key (PS_PARTKEY, PS_SUPPKEY)
            RELY DISABLE NOVALIDATE;

alter table REGION
    add constraint REGION_pk
        primary key (R_REGIONKEY)
            RELY DISABLE NOVALIDATE;

alter table SUPPLIER
    add constraint SUPPLIER_pk
        primary key (S_SUPPKEY)
            RELY DISABLE NOVALIDATE;

alter table LINEITEM
    add constraint LINEITEM_ORDERS_O_ORDERKEY_fk
        foreign key (L_ORDERKEY) references ORDERS (O_ORDERKEY)
            RELY DISABLE NOVALIDATE;

alter table LINEITEM
    add constraint LINEITEM_PART_FK
        foreign key (L_PARTKEY) references PART (P_PARTKEY)
            RELY DISABLE NOVALIDATE;

alter table LINEITEM
    add constraint LINEITEM_SUPPLIER_FK
        foreign key (L_SUPPKEY) references SUPPLIER (S_SUPPKEY)
            RELY DISABLE NOVALIDATE;

alter table PARTSUPP
    add constraint PARTSUPP_SUPP_S_SUPPKEY_fk
        foreign key (PS_SUPPKEY) references SUPPLIER (S_SUPPKEY)
            RELY DISABLE NOVALIDATE;

alter table PARTSUPP
    add constraint PARTSUPP_PART_fk
        foreign key (PS_PARTKEY) references PART (P_PARTKEY)
            RELY DISABLE NOVALIDATE;

alter table ORDERS
    add constraint ORDERS_CUSTOMER_fk
        foreign key (O_CUSTKEY) references CUSTOMER (C_CUSTKEY)
            RELY DISABLE NOVALIDATE;

alter table CUSTOMER
    add constraint CUSTOMER_NATION_fk
        foreign key (C_NATIONKEY) references NATION (N_NATIONKEY)
            RELY DISABLE NOVALIDATE;

alter table NATION
    add constraint NATION_REGION_fk
        foreign key (N_REGIONKEY) references REGION (R_REGIONKEY)
            RELY DISABLE NOVALIDATE;





