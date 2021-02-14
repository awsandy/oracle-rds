/*
|| Script:  tpce_createconstraints.sql
|| Purpose: Creates all indexes and constraints for tables that are part of
||          the TPC-E workload profile.
|| Author:  Jim Czuprynski
*/

ALTER SESSION FORCE PARALLEL DDL PARALLEL &parallelism;

ALTER SESSION FORCE PARALLEL QUERY PARALLEL &parallelism;

/*
select 'ALTER TABLE ' || table_name || ' DROP CONSTRAINT ' || constraint_name || ' CASCADE;'
  from all_constraints
 where constraint_type in ('P','R');
*/

/*
-- Create PK constraints and required indexes
*/

-----
-- Fixed and Scaling tables:
-----

ALTER TABLE account_permission
  ADD CONSTRAINT account_permission_pk
  PRIMARY KEY (ap_ca_id, ap_tax_id)
  USING INDEX (
    CREATE UNIQUE INDEX ap_pk_idx
        ON account_permission (ap_ca_id, ap_tax_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE address
  ADD CONSTRAINT address_pk
  PRIMARY KEY (ad_id)
  USING INDEX (
    CREATE UNIQUE INDEX address_pk_idx
        ON address (ad_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE broker
  ADD CONSTRAINT broker_pk
  PRIMARY KEY (b_id)
  USING INDEX (
    CREATE UNIQUE INDEX broker_pk_idx
        ON broker (b_id)
        TABLESPACE &indextablespace
    );


ALTER TABLE charge
  ADD CONSTRAINT charge_pk
  PRIMARY KEY (ch_tt_id, ch_c_tier)
  USING INDEX (
    CREATE UNIQUE INDEX charge_pk_idx
        ON charge (ch_tt_id, ch_c_tier)
        TABLESPACE &indextablespace
    );

ALTER TABLE commission_rate
  ADD CONSTRAINT commission_rate_pk
  PRIMARY KEY (cr_c_tier, cr_tt_id, cr_ex_id, cr_from_qty)
  USING INDEX (
    CREATE UNIQUE INDEX commission_rate_pk_idx
        ON commission_rate (cr_c_tier, cr_tt_id, cr_ex_id, cr_from_qty)
        TABLESPACE &indextablespace
    );

ALTER TABLE company
  ADD CONSTRAINT company_pk
  PRIMARY KEY (co_id)
  USING INDEX (
    CREATE UNIQUE INDEX company_pk_idx
        ON company (co_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE company_competitor
  ADD CONSTRAINT company_competitor_pk
  PRIMARY KEY (cp_co_id, cp_comp_co_id, cp_in_id)
  USING INDEX (
    CREATE UNIQUE INDEX company_competitor_pk_idx
        ON company_competitor (cp_co_id, cp_comp_co_id, cp_in_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE customer
  ADD CONSTRAINT customer_pk
  PRIMARY KEY (c_id)
  USING INDEX (
    CREATE UNIQUE INDEX customer_pk_idx
        ON customer(c_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE customer_account
  ADD CONSTRAINT customer_account_pk
  PRIMARY KEY (ca_id)
  USING INDEX (
    CREATE UNIQUE INDEX customer_account_pk_idx
        ON customer_account (ca_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE customer_taxrate
  ADD CONSTRAINT customer_taxrate_pk
  PRIMARY KEY (cx_tx_id, cx_c_id)
  USING INDEX (
    CREATE UNIQUE INDEX customer_taxrate_pk_idx
        ON customer_taxrate (cx_tx_id, cx_c_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE daily_market
  ADD CONSTRAINT daily_market_pk
  PRIMARY KEY (dm_date, dm_s_symb)
  USING INDEX (
    CREATE UNIQUE INDEX daily_market_pk_idx
        ON daily_market (dm_date, dm_s_symb)
        TABLESPACE &indextablespace
    );

ALTER TABLE exchange
  ADD CONSTRAINT exchange_pk
  PRIMARY KEY (ex_id)
  USING INDEX (
    CREATE UNIQUE INDEX exchange_pk_idx
        ON exchange (ex_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE financial
  ADD CONSTRAINT financial_pk
  PRIMARY KEY (fi_co_id, fi_year, fi_qtr)
  USING INDEX (
    CREATE UNIQUE INDEX financial_pk_idx
        ON financial (fi_co_id, fi_year, fi_qtr)
        TABLESPACE &indextablespace
    );

ALTER TABLE industry
  ADD CONSTRAINT industry_pk
  PRIMARY KEY (in_id)
  USING INDEX (
    CREATE UNIQUE INDEX industry_pk_idx
        ON industry (in_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE last_trade
  ADD CONSTRAINT last_trade_pk
  PRIMARY KEY (lt_s_symb)
  USING INDEX (
    CREATE UNIQUE INDEX last_trade_pk_idx
        ON last_trade (lt_s_symb)
        TABLESPACE &indextablespace
    );

ALTER TABLE news_item
  ADD CONSTRAINT news_item_pk
  PRIMARY KEY (ni_id)
  USING INDEX (
    CREATE UNIQUE INDEX news_item_pk_idx
        ON news_item (ni_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE news_xref
  ADD CONSTRAINT news_xref_pk
  PRIMARY KEY (nx_ni_id, nx_co_id)
  USING INDEX (
    CREATE UNIQUE INDEX news_xref_pk_idx
        ON news_xref (nx_ni_id, nx_co_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE sector
  ADD CONSTRAINT sector_pk
  PRIMARY KEY (sc_id)
  USING INDEX (
    CREATE UNIQUE INDEX sector_pk_idx
        ON sector (sc_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE security
  ADD CONSTRAINT security_pk
  PRIMARY KEY (s_symb)
  USING INDEX (
    CREATE UNIQUE INDEX security_pk_idx
        ON security (s_symb)
        TABLESPACE &indextablespace
    );

ALTER TABLE status_type
  ADD CONSTRAINT status_type_pk
  PRIMARY KEY (st_id)
  USING INDEX (
    CREATE UNIQUE INDEX status_type_pk_idx
        ON status_type (st_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE tax_rate
  ADD CONSTRAINT tax_rate_pk
  PRIMARY KEY (tx_id)
  USING INDEX (
    CREATE UNIQUE INDEX tax_rate_pk_idx
        ON tax_rate (tx_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE trade_type
  ADD CONSTRAINT trade_type_pk
  PRIMARY KEY (tt_id)
  USING INDEX (
    CREATE UNIQUE INDEX trade_type_pk_idx
        ON trade_type (tt_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE watch_list
  ADD CONSTRAINT watch_list_pk
  PRIMARY KEY (wl_id)
  USING INDEX (
    CREATE UNIQUE INDEX watch_list_pk_idx
        ON watch_list (wl_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE watch_item
  ADD CONSTRAINT watch_item_pk
  PRIMARY KEY (wi_wl_id, wi_s_symb)
  USING INDEX (
    CREATE UNIQUE INDEX watch_item_pk_idx
        ON watch_item (wi_wl_id, wi_s_symb)
        TABLESPACE &indextablespace
    );

ALTER TABLE zip_code
  ADD CONSTRAINT zip_code_pk
  PRIMARY KEY (zc_code)
  USING INDEX (
    CREATE UNIQUE INDEX zip_code_pk_idx
        ON zip_code (zc_code)
        TABLESPACE &indextablespace
    );

-----
-- Growing tables:
-----

ALTER TABLE cash_transaction
  ADD CONSTRAINT cash_transaction_pk
  PRIMARY KEY (ct_t_id)
  USING INDEX (
    CREATE UNIQUE INDEX cash_transaction_pk_idx
        ON cash_transaction (ct_t_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE holding
  ADD CONSTRAINT holding_pk
  PRIMARY KEY (h_t_id)
  USING INDEX (
    CREATE UNIQUE INDEX holding_pk_idx
        ON holding (h_t_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE holding_history
  ADD CONSTRAINT holding_history_pk
  PRIMARY KEY (hh_h_t_id, hh_t_id)
  USING INDEX (
    CREATE UNIQUE INDEX holding_history_pk_idx
        ON holding_history (hh_h_t_id, hh_t_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE holding_summary
  ADD CONSTRAINT holding_summary_pk
  PRIMARY KEY (hs_ca_id, hs_s_symb)
  USING INDEX (
    CREATE UNIQUE INDEX holding_summary_pk_idx
        ON holding_summary (hs_ca_id, hs_s_symb)
        TABLESPACE &indextablespace
    );

ALTER TABLE settlement
  ADD CONSTRAINT settlement_pk
  PRIMARY KEY (se_t_id)
  USING INDEX (
    CREATE UNIQUE INDEX settlement_pk_idx
        ON settlement (se_t_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE trade
  ADD CONSTRAINT trade_pk
  PRIMARY KEY (t_id)
  USING INDEX (
    CREATE UNIQUE INDEX trade_pk_idx
        ON trade (t_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE trade_history
  ADD CONSTRAINT trade_history_pk
  PRIMARY KEY (th_t_id, th_st_id)
  USING INDEX (
    CREATE UNIQUE INDEX trade_history_pk_idx
        ON trade_history (th_t_id, th_st_id)
        TABLESPACE &indextablespace
    );

ALTER TABLE trade_request
  ADD CONSTRAINT trade_request_pk
  PRIMARY KEY (tr_t_id)
  USING INDEX (
    CREATE UNIQUE INDEX trade_request_pk_idx
        ON trade_request (tr_t_id)
        TABLESPACE &indextablespace
    );

/*
-- Enable FK constraints
*/

-----
-- Fixed and Scaling tables:
-----

ALTER TABLE account_permission
    ADD CONSTRAINT ap_ca_fk
    FOREIGN KEY (ap_ca_id)
    REFERENCES customer_account (ca_id);

ALTER TABLE address
    ADD CONSTRAINT a_zc_code_fk
    FOREIGN KEY (ad_zc_code)
    REFERENCES zip_code (zc_code);

ALTER TABLE broker
    ADD CONSTRAINT b_st_fk
    FOREIGN KEY (b_st_id)
    REFERENCES status_type (st_id);

ALTER TABLE charge
    ADD CONSTRAINT ch_tt_fk
    FOREIGN KEY (ch_tt_id)
    REFERENCES trade_type (tt_id);

ALTER TABLE charge
    ADD CONSTRAINT ch_tier_ck
    CHECK (ch_c_tier IN (1,2,3));

ALTER TABLE charge
    ADD CONSTRAINT ch_chrg_ck
    CHECK (ch_chrg > 0);

ALTER TABLE commission_rate
    ADD CONSTRAINT cr_tt_fk
    FOREIGN KEY (cr_tt_id)
    REFERENCES trade_type (tt_id);

ALTER TABLE commission_rate
    ADD CONSTRAINT cr_ex_fk
    FOREIGN KEY (cr_ex_id)
    REFERENCES exchange (ex_id);

ALTER TABLE commission_rate
    ADD CONSTRAINT cr_c_tier_ck
    CHECK (cr_c_tier IN (1,2,3));

ALTER TABLE commission_rate
    ADD CONSTRAINT cr_from_qty_ck
    CHECK (cr_from_qty > 0);

ALTER TABLE commission_rate
    ADD CONSTRAINT cr_to_qty_ck
    CHECK (cr_to_qty > cr_from_qty);

ALTER TABLE commission_rate
    ADD CONSTRAINT cr_rate_ck
    CHECK (cr_rate >= 0);

ALTER TABLE company
    ADD CONSTRAINT co_st_fk
    FOREIGN KEY (co_st_id)
    REFERENCES status_type (st_id);

ALTER TABLE company
    ADD CONSTRAINT co_in_fk
    FOREIGN KEY (co_in_id)
    REFERENCES industry (in_id);

ALTER TABLE company
    ADD CONSTRAINT co_ad_fk
    FOREIGN KEY (co_ad_id)
    REFERENCES address (ad_id);

ALTER TABLE company_competitor
    ADD CONSTRAINT cp_co_fk
    FOREIGN KEY (cp_co_id)
    REFERENCES company (co_id);

ALTER TABLE company_competitor
    ADD CONSTRAINT cp_comp_co_fk
    FOREIGN KEY (cp_comp_co_id)
    REFERENCES company (co_id);

ALTER TABLE company_competitor
    ADD CONSTRAINT cp_in_fk
    FOREIGN KEY (cp_in_id)
    REFERENCES industry (in_id);

ALTER TABLE customer
    ADD CONSTRAINT c_st_fk
    FOREIGN KEY (c_st_id)
    REFERENCES status_type (st_id);

ALTER TABLE customer
    ADD CONSTRAINT c_ad_fk
    FOREIGN KEY (c_ad_id)
    REFERENCES address (ad_id);

ALTER TABLE customer
    ADD CONSTRAINT c_gndr_ck
    CHECK (c_gndr IN ('M','F'));

ALTER TABLE customer
    ADD CONSTRAINT c_tier_ck
    CHECK (c_tier IN (1,2,3));

ALTER TABLE customer_account
    ADD CONSTRAINT ca_b_fk
    FOREIGN KEY (ca_b_id)
    REFERENCES broker (b_id);

ALTER TABLE customer_account
    ADD CONSTRAINT ca_c_fk
    FOREIGN KEY (ca_c_id)
    REFERENCES customer (c_id);

ALTER TABLE customer_account
    ADD CONSTRAINT ca_tax_st_ck
    CHECK (ca_tax_st IN (0,1,2));

ALTER TABLE customer_taxrate
    ADD CONSTRAINT cx_t_fk
    FOREIGN KEY (cx_tx_id)
    REFERENCES tax_rate (tx_id);

ALTER TABLE customer_taxrate
    ADD CONSTRAINT cx_c_fk
    FOREIGN KEY (cx_c_id)
    REFERENCES customer (c_id);

ALTER TABLE daily_market
    ADD CONSTRAINT dm_s_fk
    FOREIGN KEY (dm_s_symb)
    REFERENCES security (s_symb);

ALTER TABLE exchange
    ADD CONSTRAINT ex_ad_fk
    FOREIGN KEY (ex_ad_id)
    REFERENCES address (ad_id);

ALTER TABLE financial
    ADD CONSTRAINT fi_qtr_ck
    CHECK (fi_qtr IN (1,2,3,4));

ALTER TABLE financial
    ADD CONSTRAINT fi_co_fk
    FOREIGN KEY (fi_co_id)
    REFERENCES company (co_id);

ALTER TABLE industry
    ADD CONSTRAINT in_sc_fk
    FOREIGN KEY (in_sc_id)
    REFERENCES sector (sc_id);

ALTER TABLE tax_rate
    ADD CONSTRAINT tx_rate_ck
    CHECK (tx_rate >= 0);

ALTER TABLE trade_type
    ADD CONSTRAINT tt_issell_ck
    CHECK (tt_is_sell IN (0,1));

ALTER TABLE trade_type
    ADD CONSTRAINT tt_ismrkt_ck
    CHECK (tt_is_mrkt IN (0,1));

ALTER TABLE last_trade
    ADD CONSTRAINT lt_s_fk
    FOREIGN KEY (lt_s_symb)
    REFERENCES security (s_symb);

ALTER TABLE news_xref
    ADD CONSTRAINT nx_ni_fk
    FOREIGN KEY (nx_ni_id)
    REFERENCES news_item (ni_id);

ALTER TABLE news_xref
    ADD CONSTRAINT nx_co_fk
    FOREIGN KEY (nx_co_id)
    REFERENCES company (co_id);

ALTER TABLE security
    ADD CONSTRAINT s_st_fk
    FOREIGN KEY (s_st_id)
    REFERENCES status_type (st_id);

ALTER TABLE security
    ADD CONSTRAINT s_ex_fk
    FOREIGN KEY (s_ex_id)
    REFERENCES exchange (ex_id);

ALTER TABLE security
    ADD CONSTRAINT s_co_fk
    FOREIGN KEY (s_co_id)
    REFERENCES company (co_id);

ALTER TABLE security
    ADD CONSTRAINT s_dividend_ck
    CHECK (s_dividend >= 0);

ALTER TABLE watch_list
    ADD CONSTRAINT wl_c_fk
    FOREIGN KEY (wl_c_id)
    REFERENCES customer (c_id);

ALTER TABLE watch_item
    ADD CONSTRAINT wi_wl_fk
    FOREIGN KEY (wi_wl_id)
    REFERENCES watch_list (wl_id);

ALTER TABLE watch_item
    ADD CONSTRAINT wi_s_fk
    FOREIGN KEY (wi_s_symb)
    REFERENCES security (s_symb);

-----
-- Growing tables:
-----

ALTER TABLE cash_transaction
    ADD CONSTRAINT ct_t_fk
    FOREIGN KEY (ct_t_id)
    REFERENCES trade (t_id);

ALTER TABLE holding
    ADD CONSTRAINT h_t_fk
    FOREIGN KEY (h_t_id)
    REFERENCES trade (t_id);

ALTER TABLE holding
    ADD CONSTRAINT h_ca_fk
    FOREIGN KEY (h_ca_id)
    REFERENCES customer_account (ca_id);

ALTER TABLE holding
    ADD CONSTRAINT h_s_fk
    FOREIGN KEY (h_s_symb)
    REFERENCES security (s_symb);

ALTER TABLE holding
    ADD CONSTRAINT h_price_ck
    CHECK (h_price > 0);

ALTER TABLE holding_history
    ADD CONSTRAINT hh_h_t_fk
    FOREIGN KEY (hh_h_t_id)
    REFERENCES trade (t_id);

ALTER TABLE holding_history
    ADD CONSTRAINT hh_t_fk
    FOREIGN KEY (hh_t_id)
    REFERENCES trade (t_id);

ALTER TABLE holding_summary
    ADD CONSTRAINT hs_ca_fk
    FOREIGN KEY (hs_ca_id)
    REFERENCES customer_account (ca_id);

ALTER TABLE holding_summary
    ADD CONSTRAINT hs_s_fk
    FOREIGN KEY (hs_s_symb)
    REFERENCES security (s_symb);

ALTER TABLE settlement
    ADD CONSTRAINT se_t_fk
    FOREIGN KEY (se_t_id)
    REFERENCES trade (t_id);

ALTER TABLE trade
    ADD CONSTRAINT t_st_fk
    FOREIGN KEY (t_st_id)
    REFERENCES status_type (st_id);

ALTER TABLE trade
    ADD CONSTRAINT t_tt_fk
    FOREIGN KEY (t_tt_id)
    REFERENCES trade_type (tt_id);

ALTER TABLE trade
    ADD CONSTRAINT t_s_fk
    FOREIGN KEY (t_s_symb)
    REFERENCES security (s_symb);

ALTER TABLE trade
    ADD CONSTRAINT t_ca_fk
    FOREIGN KEY (t_ca_id)
    REFERENCES customer_account (ca_id);

ALTER TABLE trade
    ADD CONSTRAINT t_iscash_ck
    CHECK (t_is_cash IN (0,1));

ALTER TABLE trade
    ADD CONSTRAINT t_lifo_ck
    CHECK (t_lifo IN (0,1));

ALTER TABLE trade
    ADD CONSTRAINT t_qty_ck
    CHECK (t_qty > 0);

ALTER TABLE trade
    ADD CONSTRAINT t_bid_price_ck
    CHECK (t_bid_price > 0);

ALTER TABLE trade
    ADD CONSTRAINT t_chrg_ck
    CHECK (t_chrg >= 0);

ALTER TABLE trade
    ADD CONSTRAINT t_comm_ck
    CHECK (t_comm >= 0);

ALTER TABLE trade
    ADD CONSTRAINT t_tax_ck
    CHECK (t_tax >= 0);

ALTER TABLE trade_history
    ADD CONSTRAINT th_t_fk
    FOREIGN KEY (th_t_id)
    REFERENCES trade (t_id);

ALTER TABLE trade_history
    ADD CONSTRAINT th_st_fk
    FOREIGN KEY (th_st_id)
    REFERENCES status_type (st_id);

ALTER TABLE trade_request
    ADD CONSTRAINT tr_t_fk
    FOREIGN KEY (tr_t_id)
    REFERENCES trade (t_id);

ALTER TABLE trade_request
    ADD CONSTRAINT tr_tt_fk
    FOREIGN KEY (tr_tt_id)
    REFERENCES trade_type (tt_id);

ALTER TABLE trade_request
    ADD CONSTRAINT tr_s_fk
    FOREIGN KEY (tr_s_symb)
    REFERENCES security (s_symb);

ALTER TABLE trade_request
    ADD CONSTRAINT tr_b_fk
    FOREIGN KEY (tr_b_id)
    REFERENCES broker (b_id);

ALTER TABLE trade_request
    ADD CONSTRAINT tr_qty_ck
    CHECK (tr_qty > 0);

ALTER TABLE trade_request
    ADD CONSTRAINT tr_bid_price_ck
    CHECK (tr_bid_price > 0);

-- End;