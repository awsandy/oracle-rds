/*
|| Script:  tpce_createsequences.sql
|| Purpose: Creates all required sequences for tables that are part of the TPC-E
||          workload profile.
|| Author:  Jim Czuprynski
*/

-- Suppress Warnings

DROP SEQUENCE address_seq;
DROP SEQUENCE broker_seq;
DROP SEQUENCE cash_transaction_seq;
DROP SEQUENCE company_seq;
DROP SEQUENCE customer_seq;
DROP SEQUENCE customer_account_seq;
DROP SEQUENCE holding_seq;
DROP SEQUENCE news_item_seq;
DROP SEQUENCE settlement_seq;
DROP SEQUENCE trade_seq;
DROP SEQUENCE watch_item_seq;

-- End Suppress Warnings

BEGIN

	DECLARE
    ad_count  NUMBER := 0;
    br_count  NUMBER := 0;
    ca_count  NUMBER := 0;
    co_count  NUMBER := 0;
    ct_count  NUMBER := 0;
    cu_count  NUMBER := 0;
    ho_count  NUMBER := 0;
    ni_count  NUMBER := 0;
    se_count  NUMBER := 0;
    ti_count  NUMBER := 0;
    wi_count  NUMBER := 0;

	BEGIN

    SELECT NVL(MAX(ad_id),0)    INTO ad_count FROM address;
    SELECT NVL(MAX(b_id),0)     INTO br_count FROM broker;
    SELECT NVL(MAX(ca_id),0)    INTO ca_count FROM customer_account;
    SELECT NVL(MAX(co_id),0)    INTO co_count FROM company;
    SELECT NVL(MAX(ct_t_id),0)  INTO ct_count FROM cash_transaction;
		SELECT NVL(MAX(c_id),0)     INTO cu_count FROM customer;
    SELECT NVL(MAX(h_t_id),0)   INTO ho_count FROM holding;
    SELECT NVL(MAX(ni_id),0)    INTO ni_count FROM news_item;
    SELECT NVL(MAX(se_t_id),0)  INTO se_count FROM settlement;
    SELECT NVL(MAX(t_id),0)     INTO ti_count FROM trade;
    SELECT NVL(MAX(wi_wl_id),0) INTO wi_count FROM watch_item;
    
    ad_count := ad_count + 1;
    br_count := br_count + 1;
    ca_count := ca_count + 1;
    co_count := co_count + 1;
    ct_count := ct_count + 1;
    cu_count := cu_count + 1;
    ho_count := ho_count + 1;
    ni_count := ni_count + 1;
    se_count := se_count + 1;
    ti_count := ti_count + 1;
    wi_count := wi_count + 1;

    EXECUTE IMMEDIATE 'CREATE SEQUENCE address_seq          START WITH ' ||ad_count|| ' CACHE 100000';  
    EXECUTE IMMEDIATE 'CREATE SEQUENCE broker_seq           START WITH ' ||br_count|| ' CACHE 100000'; 
    EXECUTE IMMEDIATE 'CREATE SEQUENCE customer_account_seq START WITH ' ||ca_count|| ' CACHE 100000'; 
    EXECUTE IMMEDIATE 'CREATE SEQUENCE company_seq          START WITH ' ||co_count|| ' CACHE 100000'; 
    EXECUTE IMMEDIATE 'CREATE SEQUENCE cash_transaction_seq START WITH ' ||ct_count|| ' CACHE 100000'; 
    EXECUTE IMMEDIATE 'CREATE SEQUENCE customer_seq         START WITH ' ||cu_count|| ' CACHE 100000'; 
    EXECUTE IMMEDIATE 'CREATE SEQUENCE holding_seq          START WITH ' ||ho_count|| ' CACHE 100000'; 
    EXECUTE IMMEDIATE 'CREATE SEQUENCE news_item_seq        START WITH ' ||ni_count|| ' CACHE 100000'; 
    EXECUTE IMMEDIATE 'CREATE SEQUENCE settlement_seq       START WITH ' ||se_count|| ' CACHE 100000'; 
    EXECUTE IMMEDIATE 'CREATE SEQUENCE trade_seq            START WITH ' ||ti_count|| ' CACHE 100000'; 
    EXECUTE IMMEDIATE 'CREATE SEQUENCE watch_item_seq       START WITH ' ||wi_count|| ' CACHE 100000'; 
		
	END;
END;
/

-- End
