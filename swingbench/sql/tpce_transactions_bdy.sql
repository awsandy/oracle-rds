CREATE OR REPLACE PACKAGE BODY TPCE.pkg_tpce_transactions
/*
|| Package Body:    PKG_TPCE_TRANSACTIONS
|| Version:         1.0
|| Description:     Generates various complex transactions against an Oracle database
||                  containing the standard TPC-E schema for evaluation of advanced
||                  SQL tuning tools and strategies
|| Author:          Jim Czuprynski
|| Last Updated On: 2019-09-27 16:00 CDT
*/
IS
/*
|| Transaction       Class                  Weight            R/W?        Status
|| ----------------- --------------------   ----------------- ----------- ----------
|| BrokerVolume      Brokerage-Initiated    Mid to Heavy      Read Only   ++ Tested
|| CustomerPosition  Customer-Initiated     Mid to Heavy      Read Only   ++ Tested
|| MarketWatch       Customer-Initiated     Medium            Read Only   ++ Tested
|| SecurityDetail    Customer-Initiated     Medium            Read Only   ++ Tested
|| TradeLookup       Brokerage-Initiated,   Medium            Read Only   ++ Tested
||                   Customer-Initiated
|| TradeStatus       Customer-Initiated     Light             Read Only   ++ Tested
|| MarketFeed        Market-Triggered       Medium            Read Write  ++ Tested
|| TradeOrder        Customer-Initiated     Heavy             Read Write  ++ Tested
|| TradeResult       Market-Triggered       Heavy             Read Write  ++ Tested
|| TradeUpdate       Brokerage-Initiated,   Medium            Read Write  ++ Tested
||                   Customer-Initiated
|| DataMaintenance   Time-Triggered         Light             Read Write  ++ Not Implemented
|| TradeCleanup      Run at Start           Medium            Read Write  ++ Tested
*/
/*
|| TYPEs and RECORDS
*/
    -----
    -- Local Functions and Procedures
    -----
    -- Processing variables:
    SQLERRNUM           INTEGER := 0;
    SQLERRMSG           VARCHAR2(255);
    SELECT_STATEMENTS   INTEGER := 1;
    INSERT_STATEMENTS   INTEGER := 2;
    UPDATE_STATEMENTS   INTEGER := 3;
    DELETE_STATEMENTS   INTEGER := 4;
    COMMIT_STATEMENTS   INTEGER := 5;
    ROLLBACK_STATEMENTS INTEGER := 6;
    SLEEP_TIME          INTEGER := 7;
    ROWS_SELECTED       INTEGER := 8;
    ROWS_PROCESSED      INTEGER := 9;
    PLSQLCOMMIT         BOOLEAN := FALSE;
    INFO_ARRAY          integer_return_array := integer_return_array();
    CNT_SYMBOLS         INTEGER := 0;
    MIN_ADDR_ID         INTEGER := 0;
    MAX_ADDR_ID         INTEGER := 0;
    MIN_CMPY_ID         INTEGER := 0;
    MAX_CMPY_ID         INTEGER := 0;
    MIN_CUST_ID         INTEGER := 0;
    MAX_CUST_ID         INTEGER := 0;
    MIN_CUST_ACCT_ID    INTEGER := 0;
    MAX_CUST_ACCT_ID    INTEGER := 0;
    MIN_RQST_QTY        INTEGER := 1;
    MAX_RQST_QTY        INTEGER := 20;
    MIN_TRADE_ID        INTEGER := 200000000000001;
    MAX_TRADE_ID        INTEGER := 0;
    DFLT_TRADE_DATE     VARCHAR2(10) := '2006-04-01';
    DFLT_CLEANUP_DATE   VARCHAR2(10) := '2006-04-03';
    --- VARRAYs for randomized control values
    TYPE va_broker_names
        IS VARRAY(40) OF VARCHAR2(49);
    TYPE va_cust_tax_ids
        IS VARRAY(20) OF VARCHAR2(14);
    TYPE va_industry_names
        IS VARRAY(25) OF VARCHAR2(50);
    TYPE va_sector_names
        IS VARRAY(12) OF VARCHAR2(30);
    TYPE va_security_symbols
        IS VARRAY(3500) OF VARCHAR2(7);
    TYPE va_trade_types
        IS VARRAY(05) OF VARCHAR2(3);
    bnames    va_broker_names;
    ctaxids   va_cust_tax_ids;
    inames    va_industry_names;
    scnames   va_sector_names;
    ssymbols  va_security_symbols;
    trtypes   va_trade_types;
    -----
    -- Processing results capture:
    -----
    PROCEDURE increment_selects(num_selects INTEGER)
    is
      BEGIN
        info_array(SELECT_STATEMENTS) := info_array(SELECT_STATEMENTS) + num_selects;
      EXCEPTION
         WHEN OTHERS THEN
           RAISE;
    END increment_selects;
    PROCEDURE increment_inserts(num_inserts INTEGER)
    IS
    BEGIN
        info_array(INSERT_STATEMENTS) := info_array(INSERT_STATEMENTS) + num_inserts;
    END increment_inserts;
    PROCEDURE increment_updates(num_updates INTEGER)
    IS
    BEGIN
        info_array(UPDATE_STATEMENTS) := info_array(UPDATE_STATEMENTS) + num_updates;
    END increment_updates;
    PROCEDURE increment_deletes(num_deletes INTEGER)
    IS
    BEGIN
        info_array(DELETE_STATEMENTS) := info_array(DELETE_STATEMENTS) + num_deletes;
    END increment_deletes;
    PROCEDURE increment_commits(num_commits INTEGER)
    IS
    BEGIN
        info_array(COMMIT_STATEMENTS) := info_array(COMMIT_STATEMENTS) + num_commits;
    END increment_commits;
    PROCEDURE increment_rollbacks(num_rollbacks INTEGER)
    IS
    BEGIN
        info_array(ROLLBACK_STATEMENTS) := info_array(ROLLBACK_STATEMENTS) + num_rollbacks;
    END increment_rollbacks;
    PROCEDURE increment_rows_selected(num_rows_selected INTEGER)
    IS
    BEGIN
        info_array(ROWS_SELECTED) := info_array(ROWS_SELECTED) + num_rows_selected;
    EXCEPTION
       WHEN OTHERS THEN
         RAISE;
    END increment_rows_selected;
    PROCEDURE increment_rows_processed(num_rows_processed INTEGER)
    IS
    BEGIN
        info_array(ROWS_PROCESSED) := info_array(ROWS_PROCESSED) + num_rows_processed;
    END increment_rows_processed;
    PROCEDURE setPLSQLCOMMIT(commitInPLSQL VARCHAR2)
    IS
    BEGIN
      IF (commitInPLSQL = 'true') THEN
          PLSQLCOMMIT := true;
      ELSE
          PLSQLCOMMIT := false;
      END IF;
    END setPLSQLCOMMIT;
    PROCEDURE oecommit
    IS
    BEGIN
      IF (PLSQLCOMMIT) THEN
          COMMIT;
          increment_commits(1);
      END IF;
    END oecommit;
    PROCEDURE init_info_array
    IS
    BEGIN
      info_array := integer_return_array();
      FOR i IN 1..10
        LOOP
          info_array.extend;
          info_array(i) := 0;
        END LOOP;
    EXCEPTION
       WHEN OTHERS THEN
         RAISE;
    END init_info_array;
    FUNCTION getdmlarrayasstring(info_array integer_return_array)
      RETURN VARCHAR
    IS
      result VARCHAR(200) := '';
    BEGIN
      result :=
        info_array(SELECT_STATEMENTS)||','||
        info_array(INSERT_STATEMENTS)||','||
        info_array(UPDATE_STATEMENTS)||','||
        info_array(DELETE_STATEMENTS)||','||
        info_array(COMMIT_STATEMENTS)||','||
        info_array(ROLLBACK_STATEMENTS)||','||
        info_array(SLEEP_TIME)||','||
        info_array(ROWS_SELECTED)||','||
        info_array(ROWS_PROCESSED);
      RETURN result;
    EXCEPTION
       WHEN OTHERS THEN
         RAISE;
    END getdmlarrayasstring;
    FUNCTION from_mills_to_tens(value INTEGER)
        RETURN FLOAT
    IS
        real_value FLOAT := 0;
    BEGIN
      real_value := value/1000;
    RETURN real_value;
    EXCEPTION
      WHEN zero_divide THEN
        real_value := 0;
        RETURN real_value;
    END from_mills_to_tens;
    FUNCTION from_mills_to_secs(value INTEGER)
        RETURN float
    IS
        real_value float := 0;
    BEGIN
        real_value := value/1000;
    RETURN real_value;
    EXCEPTION
        WHEN zero_divide THEN
            real_value := 0;
            RETURN real_value;
    END from_mills_to_secs;
    PROCEDURE sleep(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    IS
      sleeptime NUMBER := 0;
    BEGIN
      IF (max_sleep = min_sleep) THEN
        sleeptime := from_mills_to_secs(max_sleep);
        DBMS_LOCK.SLEEP(sleeptime);
      ELSIF (((max_sleep - min_sleep) > 0) AND (min_sleep < max_sleep)) THEN
        sleeptime := DBMS_RANDOM.VALUE(from_mills_to_secs(min_sleep), from_mills_to_secs(max_sleep));
        DBMS_LOCK.SLEEP(sleeptime);
      END IF;
      info_array(SLEEP_TIME) := (sleeptime * 1000) + info_array(SLEEP_TIME);
    EXCEPTION
       WHEN OTHERS THEN
         RAISE;
    END sleep;
    /*
    || Transaction Workload Generation Procedures and Functions
    */
    FUNCTION GetRandomSecuritySymbol
      RETURN VARCHAR
    /*
    || Procedure:   GetRandomSecuritySymbol
    || Scope:       PRIVATE
    || Purpose:     Retrieves a single Security symbol at random for
    ||              population of control variable during transaction
    ||              generation
    */
    IS
      result VARCHAR(7) := '';
    BEGIN
      SELECT s_symb
        INTO result
        FROM (
        SELECT s_symb
          FROM
            security
           ,(SELECT SUBSTR('ETAIONSHRDLUBCFGJKMPQVWXYZ',ROUND(DBMS_RANDOM.VALUE(1,26),0),1) first_char FROM DUAL) X
           ,(SELECT ROUND(DBMS_RANDOM.VALUE(1,3),0) pos_char FROM DUAL) P
         WHERE SUBSTR(s_symb,P.pos_char,1) = X.first_char
        )
       WHERE ROWNUM = 1;
      RETURN result;
    END GetRandomSecuritySymbol;
    FUNCTION GetRandomCompanyIdentifier
      RETURN NUMBER
    /*
    || Procedure:   GetRandomCompanyIdentifier
    || Scope:       PRIVATE
    || Purpose:     Retrieves a single Company ID at random for
    ||              population of control variable during transaction
    ||              generation
    */
    IS
      result NUMBER := 0;
    BEGIN
      SELECT ROUND(DBMS_RANDOM.VALUE(MIN_CMPY_ID,MAX_CMPY_ID),0)
        INTO result
        FROM DUAL;
      RETURN result;
    END GetRandomCompanyIdentifier;
    FUNCTION GetRandomCustomerIdentifier
      RETURN NUMBER
    /*
    || Procedure:   GetRandomCustomerIdentifier
    || Scope:       PRIVATE
    || Purpose:     Retrieves a single Customer ID at random for
    ||              population of control variable during transaction
    ||              generation
    */
    IS
      result NUMBER := 0;
    BEGIN
      SELECT ROUND(DBMS_RANDOM.VALUE(MIN_CUST_ID,MAX_CUST_ID),0)
        INTO result
        FROM DUAL;
      RETURN result;
    END GetRandomCustomerIdentifier;
    FUNCTION GetRandomCustomerAccountIdentifier
      RETURN NUMBER
    /*
    || Procedure:   GetRandomCustomerAccountIdentifier
    || Scope:       PRIVATE
    || Purpose:     Retrieves a single Customer Account ID at random for
    ||              population of control variable during transaction
    ||              generation
    */
    IS
      result NUMBER := 0;
    BEGIN
      SELECT ca_id
        INTO result
        FROM customer_account
       WHERE ca_id BETWEEN (MIN_CUST_ACCT_ID + ROUND(DBMS_RANDOM.VALUE(1,25000),0))
                       AND (MAX_CUST_ACCT_ID - ROUND(DBMS_RANDOM.VALUE(1,25000),0))
       ORDER BY ca_id
       FETCH FIRST 1 ROW ONLY;
      RETURN result;
    END GetRandomCustomerAccountIdentifier;
    FUNCTION GetRandomCustomerTaxIdentifier
      RETURN VARCHAR2
    /*
    || Procedure:   GetRandomCustomerTaxIdentifier
    || Scope:       PRIVATE
    || Purpose:     Retrieves a single Customer Tax ID at random for
    ||              population of control variable during transaction
    ||              generation
    */
    IS
      result VARCHAR2(14) := NULL;
    BEGIN
      SELECT ctaxids(ROUND(DBMS_RANDOM.VALUE(0,19),0))
        INTO result
        FROM DUAL;
      RETURN result;
    END GetRandomCustomerTaxIdentifier;
    FUNCTION GetRandomIndustryName
      RETURN VARCHAR2
    /*
    || Procedure:   GetRandomIndustryName
    || Scope:       PRIVATE
    || Purpose:     Retrieves a single Industry Name at random for
    ||              population of control variable during transaction
    ||              generation
    */
    IS
      result VARCHAR2(50) := NULL;
    BEGIN
      SELECT inames(ROUND(DBMS_RANDOM.VALUE(1,25),0))
        INTO result
        FROM DUAL;
      RETURN result;
    END GetRandomIndustryName;
    FUNCTION GetSubmittedTradesBrokerID
      RETURN NUMBER
    /*
    || Procedure:   GetSubmittedTradesBrokerID
    || Scope:       PRIVATE
    || Purpose:     Returns a single Broker ID for the Brokerage with the highest
    ||              number of submitted (i.e. unresolved) Trades for processing
    ||              via the ProcessTradeResults transaction
    */
    IS
      result      broker.b_id%TYPE := 0;
    BEGIN
      SELECT b_id
        INTO result
        FROM (
        SELECT
             b_id
            ,COUNT(*)
          FROM
             trade
            ,customer_account
            ,broker
         WHERE b_id = ca_b_id
           AND ca_id = t_ca_id
           AND t_st_id = 'SBMT'
         GROUP BY b_id
         ORDER BY 2 DESC
         FETCH FIRST 1 ROW ONLY);
      RETURN result;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN 0;
    END GetSubmittedTradesBrokerID;
    PROCEDURE InitializeAttributeArrays
    /*
    || Procedure:   GetRandomCustomerTaxIdentifier
    || Scope:       PRIVATE
    || Purpose:     Retrieves a single Customer Tax ID at random for
    ||              population of control variable during transaction
    ||              generation
    */
    IS
      va_idx PLS_INTEGER := 0;
    BEGIN
        SELECT
            MIN(ad_id)
           ,MAX(ad_id)
          INTO
            MIN_ADDR_ID
           ,MAX_ADDR_ID
          FROM address;
        SELECT
            MIN(co_id)
           ,MAX(co_id)
          INTO
            MIN_CMPY_ID
           ,MAX_CMPY_ID
          FROM company;
        SELECT
            MIN(c_id)
           ,MAX(c_id)
          INTO
            MIN_CUST_ID
           ,MAX_CUST_ID
          FROM customer;
        SELECT
            MIN(ca_id)
           ,MAX(ca_id)
          INTO
            MIN_CUST_ACCT_ID
           ,MAX_CUST_ACCT_ID
          FROM customer_account;
        SELECT COUNT(s_symb)
          INTO CNT_SYMBOLS
          FROM security;
        SELECT LAST_NUMBER
          INTO MAX_TRADE_ID
          FROM user_sequences
         WHERE sequence_name = 'TRADE_SEQ';
        -----
        -- Store random list of 20 Broker Names
        -----
        va_idx := 0;
        bnames := va_broker_names();
        FOR vcBrokerName IN (
            SELECT b_name
              FROM broker
             WHERE ROWNUM <= 40
             ORDER BY b_id DESC
           )
           LOOP
              va_idx := va_idx + 1;
              bnames.extend;
              bnames(va_idx) := vcBrokerName.b_name;
            END LOOP;
        -----
        -- Store random list of 25 Industry Names
        -----
        va_idx := 0;
        inames := va_industry_names();
        FOR vcIndustryName IN (
            SELECT in_name
              FROM industry
             WHERE ROWNUM <= 25
             ORDER BY in_id DESC
           )
           LOOP
              va_idx := va_idx + 1;
              inames.extend;
              inames(va_idx) := vcIndustryName.in_name;
            END LOOP;
        -----
        -- Store random list of 20 Customer Tax IDs
        -----
        va_idx := 0;
        ctaxids := va_cust_tax_ids();
        FOR vcCustTaxID IN (
            SELECT c_tax_id
              FROM customer
             WHERE SUBSTR(c_id, 7, 3) IN ('125','625')
               AND ROWNUM <= 20
           ORDER BY c_tax_id
           )
           LOOP
              va_idx := va_idx + 1;
              ctaxids.extend;
              ctaxids(va_idx) := vcCustTaxID.c_tax_id;
            END LOOP;
        -----
        -- Store random list of Sector Names
        -----
        va_idx := 0;
        scnames := va_sector_names();
        FOR vcSectorName IN (
            SELECT sc_name
              FROM sector
           ORDER BY sc_name
           )
           LOOP
              va_idx := va_idx + 1;
              scnames.extend;
              scnames(va_idx) := vcSectorName.sc_name;
            END LOOP;
        -----
        -- Store list of Trade Types
        -----
        va_idx := 0;
        trtypes := va_trade_types();
        FOR vcTradeTypes IN (
            SELECT tt_id
              FROM trade_type
           ORDER BY 1
           )
           LOOP
              va_idx := va_idx + 1;
              trtypes.extend;
              trtypes(va_idx) := vcTradeTypes.tt_id;
            END LOOP;
        -----
        -- Store random list of Security Symbols
        -----
        va_idx := 0;
        ssymbols := va_security_symbols();
        FOR vcSymbols IN (
            SELECT s_symb
              FROM security
           ORDER BY s_name
           )
           LOOP
              va_idx := va_idx + 1;
              ssymbols.extend;
              ssymbols(va_idx) := vcSymbols.s_symb;
            END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            SQLERRNUM := SQLCODE;
            SQLERRMSG := SQLERRM;
            RAISE;
    END InitializeAttributeArrays;
    -----
    -- Procedure:   ProcessTradeResult
    -- Scope:       PRIVATE
    -- Purpose:     Emulates the process of completing a Stock Market Trade.
    --              It represents thr process that a Brokerage House would
    --              perform after receiving the final confirmation and price
    --              for the Trade, including updating the Customer's Holdings
    --              to reflect that the Trade is completed.
    -- Notes:       See TPC-E Specification Section 3.3.8
    -----
    PROCEDURE ProcessTradeResult(
       nTradeID     trade.t_id%TYPE
    )
    IS
      vcSymbol            trade.t_s_symb%TYPE;
      nTradePrice         trade.t_trade_price%TYPE;
      nTradeQty           trade.t_qty%TYPE;
      vcTradeType         trade.t_tt_id%TYPE;
      vcCashTransName     cash_transaction.ct_name%TYPE;
      nCommRate           commission_rate.cr_rate%TYPE := 0;
      nCustID             customer.c_id%TYPE;
      nCustTier           customer.c_tier%TYPE;
      nBrokerID           customer_account.ca_b_id%TYPE;
      nTaxStatus          customer_account.ca_tax_st%TYPE;
      nCustAcctID         customer_account.ca_id%TYPE;
      nCustBalance        customer_account.ca_bal%TYPE;
      nOrigTradeID        holding.h_t_id%TYPE;
      nExchgID            security.s_ex_id%TYPE;
      vcSecName           security.s_name%TYPE;
      dtSettleDue         settlement.se_cash_due_date%TYPE;
      nSettleAmt          settlement.se_amt%TYPE;
      vcSettleCashType    settlement.se_cash_type%TYPE;
      nTaxRate            tax_rate.tx_rate%TYPE := 0;
      tsTradeCompleted    trade.t_dts%TYPE;
      nChrgAmt            trade.t_chrg%TYPE;
      nCommAmt            trade.t_comm%TYPE;
      bIsCash             trade.t_is_cash%TYPE;
      nHeldQty            trade.t_qty%TYPE := 0;
      nNeededQty          trade.t_qty%TYPE := 0;
      nHeldPrice          trade.t_trade_price%TYPE := 0;
      bIsLifo             trade.t_lifo%TYPE;
      vcTradeDesc         trade_type.tt_name%TYPE;
      bAtMrkt             trade_type.tt_is_mrkt%TYPE;
      bIsSale             trade_type.tt_is_sell%TYPE;
      NoSuchTrade         EXCEPTION;
      CycleBackLater      EXCEPTION;
      nBuyValue           NUMBER := 0;
      nSellValue          NUMBER := 0;
      nTaxableAmt         NUMBER := 0;
      TYPE typTradeID
        IS TABLE OF holding.h_t_id%TYPE
        INDEX BY PLS_INTEGER;
      colOrigTID     typTradeID;
      TYPE typHoldQty
        IS TABLE OF holding.h_qty%TYPE
        INDEX BY PLS_INTEGER;
      colHoldQty     typHoldQty;
      TYPE typTradePrice
        IS TABLE OF holding.h_price%TYPE
        INDEX BY PLS_INTEGER;
      colHoldPrice   typTradePrice;
      CURSOR curOldestHoldingsFirst IS
        SELECT h_t_id, h_qty, h_price
          FROM holding
         WHERE h_ca_id = nCustAcctID
           AND h_s_symb = vcSymbol
         ORDER BY h_dts ASC;
      CURSOR curNewestHoldingsFirst IS
        SELECT h_t_id, h_qty, h_price
          FROM holding
         WHERE h_ca_id = nCustAcctID
           AND h_s_symb = vcSymbol
         ORDER BY h_dts DESC;
    BEGIN
        DBMS_APPLICATION_INFO.SET_MODULE('Trade Result Transaction',NULL);
        init_info_array();
        -----
        -- Frame 1: Trade Information
        -- Gather information about a single +requested+ Trade:
        -- 1.) Determine selected trade's Trade Type attributes
        -- 2.) Determine if any shares are currently held for the selected Trade's
        --     Customer Account and Security; if none exist, then set Held Quantity
        --     to zero (0)
        -----
        BEGIN
          SELECT
               t_ca_id
              ,t_tt_id
              ,t_s_symb
              ,t_qty
              ,t_trade_price
              ,t_chrg
              ,t_lifo
              ,t_is_cash
            INTO
               nCustAcctID
              ,vcTradeType
              ,vcSymbol
              ,nTradeQty
              ,nTradePrice
              ,nChrgAmt
              ,bIsLIFO
              ,bIsCash
            FROM trade
           WHERE t_id = nTradeID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             RAISE NoSuchTrade;
        END;
        -----
        -- Get trade characteristics based on the type of trade:
        --
        -- Trade               Sell/    At
        -- Code   Trade Type   Buy?     Market?
        -- -----  -----------  -------  -------
        -- TMB    Market-Buy   0 (no)   1 (yes)
        -- TMS    Market-Sell  1 (yes)  1 (yes)
        -- TSL    Stop-Loss    1 (yes)  0 (no)
        -- TLS    Limit-Sell   1 (yes)  0 (no)
        -- TLB    Limit-Buy    0 (no)   0 (no)
        -----
        SELECT
             tt_name
            ,tt_is_mrkt
            ,tt_is_sell
          INTO
             vcTradeDesc
            ,bAtMrkt
            ,bIsSale
          FROM trade_type
         WHERE tt_id = vcTradeType;
         BEGIN
           SELECT hs_qty
            INTO nHeldQty
            FROM holding_summary
           WHERE hs_ca_id = nCustAcctID
           AND hs_s_symb = vcSymbol;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             nHeldQty := 0;
         END;
        -----
        -- Frame 2:
        -- Buy/Sell Transaction Processing (taken directly from TPC-E Benchmark Documentation)
        --
        -- The customer�s holdings are updated to reflect the completion of the trade. The
        -- particular work done depends on:
        --   a) the type of trade (buy or sell),
        --   b) the number of shares involved, and
        --   c) the customer�s current position (long or short) with respect to the security.
        --
        -- When selling shares, current holdings are liquidated to cover the sale.  If the
        -- customer does not have enough shares to cover the sale:
        --   a) any currently held shares are liquidated; and
        --   b) a short position is taken for the balance of shares.
        --
        -- If the customer already has a short position and more shares are sold,
        -- then the short position is simply extended.
        --
        -- An analogous situation exists when purchasing shares:
        --   a) Any shares bought will first be used to cover any existing short position.
        --   b) After that, any shares bought will be used to create or extend a long position.
        -----
        -- Initialize variables
        nBuyValue  := 0;
        nSellValue := 0;
        nNeededQty := nTradeQty;
        -- Use default transaction date and time for any trades executed
        tsTradeCompleted :=
          TO_TIMESTAMP((DFLT_TRADE_DATE || '.' ||ROUND(DBMS_RANDOM.VALUE(13,15),0) || ':' ||
                ROUND(DBMS_RANDOM.VALUE(10,59),0) || ':' || ROUND(DBMS_RANDOM.VALUE(10,59),0)),
                'YYYY-MM-DD.HH24:MI:SS');
        -- Gather customer account-specific information for any trade processing
        SELECT
             ca_b_id
            ,ca_c_id
            ,ca_tax_st
          INTO
            nBrokerID
           ,nCustID
           ,nTaxStatus
          FROM customer_account
         WHERE ca_id = nCustAcctID;
        -----
        -- Next, process the Trade via one of the four mutually-exclusive logic flows:
        -- 1.) Standard Sale
        -- 2.) Short Sale
        -- 3.) Short Cover
        -- 4.) Standard Buy
        -----
        -- Is this a Sale (1) or a Buy (0)?
        -----
        IF (bIsSale = 1) THEN
          BEGIN
            -----
            -- #1 - Standard Sale Trade Processing:
            -----
            -- A security is being sold, so determine how many shares are currently
            -- held (if any):
            -----
            IF (nHeldQty = 0) THEN
              -----
              -- A.) There are zero (0) shares currently held, so add a new entry into
              -- HOLDING_SUMMARY to reflect this. The number of shares are recorded
              -- as a negative balance reflecting the number of shares to be traded ...
              -----
              BEGIN
                INSERT INTO holding_summary (
                     hs_ca_id
                    ,hs_s_symb
                    ,hs_qty)
                VALUES (
                     nCustAcctID
                    ,vcSymbol
                    ,(-1 * nTradeQty) );
              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  RAISE CycleBackLater;
              END;
              increment_inserts(1);
            ELSE
              -----
              -- B.) ...otherwise, some shares +are+ currently held (i.e. nHeldQty <> 0);
              -- therefore, compare the number of shares held vs. number to be traded. If
              -- they aren't exactly equal, subtract the number of shares to be traded
              -- from the current number of shares already held in HOLDING_SUMMARY.
              -----
              IF (nHeldQty <> nTradeQty) THEN
                UPDATE holding_summary
                   SET hs_qty = (hs_qty - nTradeQty)
                 WHERE hs_ca_id = nCustAcctID
                   AND hs_s_symb = vcSymbol;
                increment_updates(1);
              END IF;
            END IF;
            IF (nHeldQty > 0) THEN
              -----
              --  There are at least some shares held for this Security, so ...
              -----
              IF (bIsLIFO = 1) THEN
              -----
              -- ... determine the order in which to process them, either:
              -- a) Last-In, First Out (LIFO)  (i.e. descending order based on trade date); or
              -- b) First-In, First-Out (FIFO) (i.e. ascending order based on trade date)
              -----
                OPEN  curNewestHoldingsFirst;
                FETCH curNewestHoldingsFirst BULK COLLECT INTO colOrigTID, colHoldQty, colHoldPrice;
                CLOSE curNewestHoldingsFirst;
              ELSE
                OPEN curOldestHoldingsFirst;
                FETCH curOldestHoldingsFirst BULK COLLECT INTO colOrigTID, colHoldQty, colHoldPrice;
                CLOSE curOldestHoldingsFirst;
              END IF;
              -----
              -- Since this is a Sale order, holdings must be liquidated. Therefore,
              -- cycle through all existing holdings in either LIFO or FIFO order
              -- until the total number of shares to satisfy the sale have been
              -- processed
              -----
              FOR h IN 1 .. colOrigTID.COUNT
                LOOP
                  EXIT WHEN (nNeededQty = 0);
                  nOrigTradeID   := colOrigTID(h);
                  nHeldQty       := colHoldQty(h);
                  nHeldPrice     := colHoldPrice(h);
                  -----
                  -- If the number of shares held is still greater than the number
                  -- needed to complete the sale ...
                  -----
                  IF (nHeldQty > nNeededQty) THEN
                    BEGIN
                      -----
                      -- A. Add a new entry into HOLDING_HISTORY to reflect the
                      --    new number of shares held
                      -----
                      BEGIN
                        INSERT INTO holding_history (
                           hh_h_t_id
                          ,hh_t_id
                          ,hh_before_qty
                          ,hh_after_qty)
                        VALUES (
                           nOrigTradeID               -- Trade ID of the +original+ trade
                          ,nTradeID                   -- Trade ID of the +current+ trade
                          ,nHeldQty                   -- +Original+ quantity held
                          ,(nHeldQty - nNeededQty) ); -- +Current+ quantity after trade
                      EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                          DBMS_OUTPUT.PUT_LINE('>> SaleOrderReduction: HH_H_TID: ' || nOrigTradeID || ' HH_TID: ' || nTradeID);
                          RAISE CycleBackLater;
                      END;
                      increment_inserts(1);
                      -----
                      -- B. Update the corresponding entry in HOLDING to reflect
                      --    the new holding quantity, subtracting the number of
                      --    shares needed from those originally held
                      -----
                      UPDATE holding
                         SET h_qty = (nHeldQty - nNeededQty)
                       WHERE h_t_id = nOrigTradeID
                         AND h_ca_id = nCustAcctID;
                      increment_updates(1);
                      -----
                      -- C. Calculate the new total value of shares bought and sold
                      --    as a result of the Trade
                      -----
                      nBuyValue   := nBuyValue  + (nNeededQty * nHeldPrice);
                      nSellValue  := nSellValue + (nNeededQty * nTradePrice);
                      nNeededQty  := 0;
                    END;
                  ELSE
                    BEGIN
                      -----
                      -- At this point, all Holdings have been reduced to zero (0), so:
                      -- A. Add a new entry into HOLDING_HISTORY to reflect a total of zero (0)
                      --    shares held
                      -----
                      BEGIN
                        INSERT INTO holding_history (
                            hh_h_t_id
                           ,hh_t_id
                           ,hh_before_qty
                           ,hh_after_qty)
                        VALUES (
                            nOrigTradeID  -- Trade ID of the +original+ trade
                           ,nTradeID      -- Trade ID of the +current+ trade
                           ,nHeldQty      -- +Original+ quantity held
                           ,0);           -- +Current+ quantity held (zero)H_QTY after delete
                      EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                          DBMS_OUTPUT.PUT_LINE('>> SaleOrderLiquidation: HH_H_TID: ' || nOrigTradeID || ' HH_TID: ' || nTradeID);
                          RAISE CycleBackLater;
                      END;
                      increment_inserts(1);
                      -----
                      -- B. Delete the original trade entry from HOLDING to reflect its
                      --    zero (0) +Current+ quantity held (zero)balance
                      -----
                      DELETE FROM holding
                       WHERE h_t_id = nOrigTradeID
                         AND h_ca_id = nCustAcctID;
                      increment_deletes(1);
                      -----
                      -- C. Calculate the new total value of shares bought and sold as a
                      --    result of the trade
                      -----
                      nBuyValue:= nBuyValue + (nHeldQty * nHeldPrice);
                      nSellValue  := nSellValue + (nHeldQty * nTradePrice);
                      nNeededQty  := (nNeededQty - nHeldQty);
                    END;
                  END IF;
                END LOOP;
            -- END of Standard Sale logic
            END IF;
            -----
            -- #2 - Short Sale Processing:
            -- If the needed quantity is still greater than zero (0), then the
            -- Customer has sold all existing holdings and is therefore selling
            -- short.
            -----
            IF (nNeededQty > 0) THEN
              BEGIN
                -----
                -- A. Add a new entry into HOLDING_HISTORY to reflect a negative
                --    quantity equal to that of the remaining needed shares
                -----
                BEGIN
                  INSERT INTO holding_history (
                       hh_h_t_id
                      ,hh_t_id
                      ,hh_before_qty
                      ,hh_after_qty)
                  VALUES (
                      nTradeID            -- Trade ID of the +current+ trade << ??? CONFIRM THIS IN NARRATIVE!!
                     ,nTradeId            -- Trade ID of the +current+ trade
                     ,0                   -- +Original+ quantity held
                     ,(-1) * nNeededQty); -- +Current+ quantity held set to a negative value, b/c this is a short sale
                EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                    DBMS_OUTPUT.PUT_LINE('>> ShortSale: HH_H_TID: ' || nTradeID || ' HH_TID: ' || nTradeID);
                    RAISE CycleBackLater;
                END;
                increment_inserts(1);
                -----
                -- B. Add a new entry into HOLDING to reflect a negative
                --    quantity equal to that of the remaining needed shares
                -----
                INSERT INTO holding (
                    h_t_id
                   ,h_ca_id
                   ,h_s_symb
                   ,h_dts
                   ,h_price
                   ,h_qty)
                VALUES (
                    nTradeID
                   ,nCustAcctID
                   ,vcSymbol
                   ,tsTradeCompleted
                   ,nTradePrice
                   ,(-1) * nNeededQty);
                increment_inserts(1);
              END;
            ELSE
             -----
              -- C. If the quantity in HOLDING_SUMMARY is exactly equal to the quantity
              -- of shares being traded, then remove the entry completely from that table
              -----
              IF (nHeldQty = nTradeQty) THEN
                  DELETE FROM holding_summary
                   WHERE hs_ca_id = nCustAcctID
                    AND hs_s_symb = vcSymbol;
                  increment_deletes(1);
              END IF;
            -- End of Short Sale processing
            END IF;
          -----
          -- END of all Sell Trade activities
          -----
          END;
       --+++
       ELSE
       --+++
          -----
          -- START of all Buy Trade Processing
          -----
          BEGIN
            -----
            -- #3 - Standard Buy Trade Processing:
            -- A security is being ++bought++, so verify the number of shares
            -- currently held.
            -----
            IF (nHeldQty = 0) THEN
              -----
              -- If the nunmber of shares held is zero (0), then there are no
              -- prior holdings, and this is a first-time purchase; therefore,
              -- add a new entry into HOLDING_SUMMARY to reflect the quantity
              -- being purchased ...
              -----
              BEGIN
                INSERT INTO holding_summary (
                    hs_ca_id
                   ,hs_s_symb
                   ,hs_qty
                )
                VALUES (
                    nCustAcctID
                   ,vcSymbol
                   ,nTradeQty
                );
                increment_inserts(1);
              EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  DBMS_OUTPUT.PUT_LINE('>> StandardBuyTrade - Zero Shares: HS_CA_ID: ' || nCustAcctID || ' HS_S_SYMB: ' || vcSymbol || ' HS_QTY: ' || nTradeQty);
                  RAISE CycleBackLater;
              END;
            ELSE
              -----
              -- ... otherwise, some prior holdings do exist, so:
              -- 1.) Multiply the currently-held shares by (-1) and then compare
              --     it to the number of shares to be traded.
              -- 2.) If they are not identical, it's necessary to update the
              --     total number of held shares in HOLDING_SUMMARY to reflect
              --     the new balance as the sum of Held and Traded quantities.
              -----
              IF ( ((-1) * nHeldQty) <> nTradeQty) THEN
                 UPDATE holding_summary
                    SET hs_qty = (nHeldQty + nTradeQty)
                  WHERE hs_ca_id = nCustAcctID
                    AND hs_s_symb = vcSymbol;
                 increment_updates(1);
              END IF;
            END IF;
            -----
            -- 3.) Short Cover Processing:
            -- If the number of shares held is +still+ negative, then this means
            -- there must have been a previous short sale, so this Buy Trade will
            -- actually "cover" that Short Sale.
            -----
            IF (nHeldQty < 0) THEN
              -----
              -- ... determine the order in which to process them, either:
              -- a) Last-In, First Out (LIFO)  (i.e. descending order based on trade date); or
              -- b) First-In, First-Out (FIFO) (i.e. ascending order based on trade date)
              -----
              IF (bIsLIFO = 1) THEN
                OPEN  curNewestHoldingsFirst;
                FETCH curNewestHoldingsFirst BULK COLLECT INTO colOrigTID, colHoldQty, colHoldPrice;
                CLOSE curNewestHoldingsFirst;
              ELSE
                OPEN curOldestHoldingsFirst;
                FETCH curOldestHoldingsFirst BULK COLLECT INTO colOrigTID, colHoldQty, colHoldPrice;
                CLOSE curOldestHoldingsFirst;
              END IF;
             -----
              -- Since this is a Short Cover, securities must be bought back in
              -- order to cover those short positions. Therefore, cycle through all
              -- short positions existing holdings in either LIFO or FIFO order
              -- until the total number of shares to satisfy the sale have been
              -- processed.
              -----
              FOR h IN 1 .. colOrigTID.COUNT
                LOOP
                  EXIT WHEN (nNeededQty = 0);
                  nOrigTradeID   := colOrigTID(h);
                  nHeldQty       := colHoldQty(h);
                  nHeldPrice     := colHoldPrice(h);
                  -----
                  -- If the number of shares held plus the number of shares needed
                  -- is still negative (indicating the Short Cover isn't yet
                  -- fulfilled, then ...
                  -----
                  IF ( (nHeldQty + nNeededQty)  < 0) THEN
                    BEGIN
                      -----
                      -- A. Add a new entry into HOLDING_HISTORY reflecting the
                      --    "before" trade quantity as the quantity currently held, and
                      --    and the "after" quantity as the total of held and needed
                      --    quantity;
                      -----
                      BEGIN
                        INSERT INTO holding_history (
                           hh_h_t_id
                          ,hh_t_id
                          ,hh_before_qty
                          ,hh_after_qty)
                        VALUES (
                           nOrigTradeID             -- Original Trade ID
                          ,nTradeID                 -- Current Trade ID
                          ,nHeldQty                 -- Current Held Quantity
                          ,nHeldQty + nNeededQty);  -- New Held Quantity
                      EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                          DBMS_OUTPUT.PUT_LINE('>> ShortCoverLiquidation: HH_H_TID: ' || nOrigTradeID || ' HH_TID: ' || nTradeID);
                          RAISE CycleBackLater;
                      END;
                      increment_inserts(1);
                      -----
                      -- B. Update the quantity of the current HOLDING entry for the original
                      --    trade to reflect the total of the held and needed quantity; and
                      -----
                      UPDATE holding
                        SET h_qty = (nHeldQty + nNeededQty)
                      WHERE h_t_id = nOrigTradeID
                        AND h_ca_id = nCustAcctID;
                      increment_updates(1);
                      -----
                      -- C. Calculate the new total value of shares bought and sold as a
                      --    result of the trade, setting the Needed quantity to zero (0).
                      -----
                      nSellValue  := nSellValue + (nNeededQty * nHeldPrice);
                      nBuyValue   := nBuyValue  + (nNeededQty * nTradePrice);
                      nNeededQty  := 0;
                    END;
                  ELSE
                    -----
                    -- ... otherwise if the sum of Held and Needed quantities is
                    -- *still* negative, it's necessary to buy back the entirety
                    -- of the original short sale of the security to complete the
                    -- Short Cover process.
                    -----
                    BEGIN
                      -----
                      -- A. Add a new entry into HOLDING_HISTORY reflecting the
                      --    "before" trade quantity as the quantity currently held, and
                      --    and the "after" quantity as zero (0);
                      -----
                      BEGIN
                        INSERT INTO holding_history (
                            hh_h_t_id -- << Confirm proper source!! Coming up NULL.
                           ,hh_t_id
                           ,hh_before_qty
                           ,hh_after_qty)
                        VALUES (
                            nOrigTradeID  -- Original Trade ID
                           ,nTradeID      -- Current Trade ID
                           ,nHeldQty      -- Current Held Quantity
                           ,0);           -- Held Quantity post-deletion
                      EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                          DBMS_OUTPUT.PUT_LINE('>> ShortCoverPostDeletion: HH_H_TID: ' || nOrigTradeID || ' HH_TID: ' || nTradeID);
                          RAISE CycleBackLater;
                      END;
                      increment_inserts(1);
                      -----
                      -- B. Delete the current HOLDING entry for the originally-held Trade; and
                      -----
                      DELETE FROM holding
                       WHERE h_t_id = nOrigTradeID
                         AND h_ca_id = nCustAcctID;
                      increment_deletes(1);
                      -----
                      -- C. Calculate the new total value of shares bought and sold as a
                      --    result of the trade, reducing the Needed quantity by the eliminated
                      --    Held quantity. Note that HOLD_QTY is set to a positive value for
                      --    easy calculations
                      -----
                      nHeldQty    := (-1) * nHeldQty;
                      nSellValue  := nSellValue + (nHeldQty * nHeldPrice);
                      nBuyValue   := nBuyValue  + (nHeldQty * nTradePrice);
                      nNeededQty  := (nNeededQty - nHeldQty);
                    END;
                  -- END of Short Cover logic
                  END IF;
                -- END of Short Cover processing loop
                END LOOP;
              -----
              -- #4 - Buy Trade Processing:
              -- If the Needed quantity is still greater than zero (0), this means
              -- the customer has already covered any previous short sales and will be
              -- is buying brand-new holdings, so:
              -----
              IF (nNeededQty > 0) THEN
                BEGIN
                  -----
                  -- A. Add a new entry into HOLDING_HISTORY reflecting the
                  --    "before" trade quantity as zero (0) - it's a new purchase! -
                  --    and the "after" quantity equal to the number of shared needed ...
                  -----
                  BEGIN
                    INSERT INTO holding_history (
                        hh_h_t_id
                       ,hh_t_id
                       ,hh_before_qty
                       ,hh_after_qty)
                    VALUES (
                        nTradeID        -- Trade ID of original trade
                       ,nTradeID        -- Current Trade ID
                       ,0               -- Quantity before original trade (zero, since this is a brand-new trade!)
                       ,nNeededQty);    -- Quantity after  original trade
                  EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN
                      DBMS_OUTPUT.PUT_LINE('>> Buy: HH_H_TID: ' || nTradeID || ' HH_TID: ' || nTradeID);
                      RAISE CycleBackLater;
                  END;
                  increment_inserts(1);
                  -----
                  -- B. ... and add a new HOLDING entry reflectng the newly-purhased security
                  -----
                  INSERT INTO holding (
                      h_t_id
                     ,h_ca_id
                     ,h_s_symb
                     ,h_dts
                     ,h_price
                     ,h_qty)
                  VALUES (
                      nTradeID
                     ,nCustAcctID
                     ,vcSymbol
                     ,tsTradeCompleted
                     ,nTradePrice
                     ,nNeededQty);
                  increment_inserts(1);
                END;
              ELSE
                -----
                -- Finally, determine if at this point the negative of the quantity
                -- held is precisely equal to the quantity being traded. If so, remove
                -- any remaining holdings from HOLDING_SUMMARY
                -----
                IF ((-1 * nHeldQty) = nTradeQty) THEN
                  DELETE FROM holding_summary
                   WHERE hs_ca_id = nCustAcctID
                    AND hs_s_symb = vcSymbol;
                  increment_deletes(1);
                END IF;
              END IF;
            -- END of Short Cover Processing
            END IF;
          -- END of #3 and #4 Logic Branch
          END;
        -----
        -- End of Frame #2
        -----
        END IF;
        -----
        -- Frame 3:
        -- Calculate Taxable Amount (if any)
        -- a.) Retrieve the total Tax Rate applicable for the specified Customer
        -- b.) If the Customer Account's Tax status is Taxable (1 or 2)
        --       then calculate the Taxable Amount and record it for the Trade
        -----
        nTaxableAmt := 0;
        IF ( (nTaxStatus IN (1,2) )
        AND (nSellValue > nBuyValue) ) THEN
          BEGIN
            SELECT SUM(tx_rate)
              INTO nTaxRate
              FROM tax_rate
             WHERE tx_id IN (SELECT cx_tx_id
                               FROM customer_taxrate
                              WHERE cx_c_id = nCustID);
            nTaxableAmt := (nSellValue - nBuyValue) * nTaxRate;
            UPDATE trade
               SET t_tax = nTaxableAmt
             WHERE t_id = nTradeId;
            increment_updates(1);
          END;
        END IF;
        -----
        -- Frame 4:
        -- Commission Rate Determination
        -- Get the very first Commission Rate based on:
        -- a.) the selected Security; and
        -- b.) the Tier for the selected Customer
        -----
        BEGIN
          SELECT
               s_ex_id
              ,s_name
            INTO
               nExchgID
              ,vcSecName
            FROM security
           WHERE s_symb = vcSymbol;
          SELECT c_tier
            INTO nCustTier
            FROM customer
           WHERE c_id = nCustID;
          SELECT
            cr_rate
            INTO nCommRate
            FROM commission_rate
           WHERE cr_c_tier = nCustTier
             AND cr_tt_id = vcTradeType
             AND cr_ex_id = nExchgID
             AND cr_from_qty <= nTradeQty
             AND cr_to_qty >= nTradeQty;
        END;
        -----
        -- Frame 5:
        -- Commission Determination and Posting
        -----
        nCommAmt := (nCommRate / 100) * (nTradeQty * nTradePrice);
        BEGIN
          UPDATE trade
             SET t_comm = nCommAmt
                ,t_dts = tsTradeCompleted
                ,t_st_id = 'CMPT'
                ,t_trade_price = nTradePrice
           WHERE t_id = nTradeId;
          increment_updates(1);
          BEGIN
            INSERT INTO trade_history (
                th_t_id
               ,th_dts
               ,th_st_id)
            VALUES (
                nTradeID
               ,tsTradeCompleted
               ,'CMPT');
            increment_inserts(1);
          EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                  DBMS_OUTPUT.PUT_LINE('>> Commission Determination: TH_T_ID: ' || nTradeID || ' TH_ST_ID: ' || 'CMPT');
              RAISE CycleBackLater;
          END;
          UPDATE broker
             SET b_comm_total = b_comm_total + nCommAmt
                ,b_num_trades = b_num_trades + 1
           WHERE b_id = nBrokerID;
          increment_updates(1);
        END;
        -----
        -- Frame 6: Settle the Trade
        -- 1.) Determine if this Trade will be settle via either a Cash or Margin transaction
        -- 2.) Derive an appropriate Settlement Date
        -- 3.) Calculate the Settlement Amount depending on whether it's a Sell or Buy Trade
        -- 4.) Add an appropriate Settlement entry for the Trade
        -- 5.) If this is a Cash Transaction,
        --     a.) Update the Customer's Account balance to reflect either the Trade's
        --         proceeds (Sell) or costs (Buy); and
        --     b.) Add a new Cash Transaction entry
        -- 6.) Query the Cash Account's new balance
        -----
        IF (bIsCash = 1) THEN
           vcSettleCashType := 'Cash Account';
        ELSE
          vcSettleCashType  := 'Margin';
        END IF;
        dtSettleDue := TO_DATE(DFLT_TRADE_DATE,'yyyy-mm-dd') - 2;
        IF (bIsSale = 1) THEN
          nSettleAmt := (nTradeQty * nTradePrice) - (nChrgAmt + nCommAmt);
        ELSE
          nSettleAmt := (-1) * ((nTradeQty * nTradePrice) + (nChrgAmt + nCommAmt));
        END IF;
        IF (nTaxStatus = 1) THEN
          nSettleAmt := (nSettleAmt - nTaxableAmt);
        END IF;
        INSERT INTO settlement (
            se_t_id
           ,se_cash_type
           ,se_cash_due_date
           ,se_amt)
        VALUES (
            nTradeId
           ,vcSettleCashType
           ,dtSettleDue
           ,nSettleAmt);
        increment_inserts(1);
        IF (bIsCash = 1) THEN
          vcCashTransName := vcTradeType || ' ' || nTradeQty || ' shares of ' || vcSecName ;
          BEGIN
            UPDATE customer_account
               SET ca_bal = ca_bal + nSettleAmt
             WHERE ca_id = nCustAcctID;
            increment_updates(1);
            INSERT INTO cash_transaction (
                ct_dts
               ,ct_t_id
               ,ct_amt
               ,ct_name)
            VALUES (
               tsTradeCompleted
              ,nTradeID
              ,nSettleAmt
              ,vcCashTransName);
            increment_inserts(1);
          END;
        END IF;
        SELECT ca_bal
          INTO nCustBalance
          FROM customer_account
         WHERE ca_id = nCustAcctID;
        increment_selects(1);
        COMMIT;
        increment_commits(1);
        DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
        EXCEPTION
          WHEN NoSuchTrade THEN
            ROLLBACK;
            increment_rollbacks(1);
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
          WHEN CycleBackLater THEN
            ROLLBACK;
            increment_rollbacks(1);
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
          WHEN OTHERS THEN
            ROLLBACK;
            increment_rollbacks(1);
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
            RAISE;
    END ProcessTradeResult;
    /*
    || Query Transactions:
    */
    -----
    -- Function:    QryBrokerVolume
    -- Scope:       PUBLIC
    -- Purpose:     Emulates a Brokerage House's up-to-the minute internal
    --              business reporting that summarizes the performance of
    --              a random sample of Brokers for a random Sector
    -- Usage Notes: TPC-E Specification 3.3.1
    -----
    FUNCTION QryBrokerVolume (
       min_sleep INTEGER
      ,max_sleep INTEGER
    )
    RETURN integer_return_array
    IS
      CURSOR curBrokerVolume IS
        SELECT
            b_name
           ,SUM(tr_qty * tr_bid_price) AS volume
          FROM
             trade_request
            ,sector
            ,industry
            ,company
            ,broker
            ,security
         WHERE tr_b_id = b_id
           AND tr_s_symb = s_symb
           AND s_co_id = co_id
           AND co_in_id = in_id
           AND sc_id = in_sc_id
           AND b_name IN (
               bnames(ROUND(DBMS_RANDOM.VALUE(1,10),0))
              ,bnames(ROUND(DBMS_RANDOM.VALUE(11,20),0))
              ,bnames(ROUND(DBMS_RANDOM.VALUE(1,20),0))
               )
           AND sc_name = scnames(ROUND(DBMS_RANDOM.VALUE(1,12),0))
         GROUP BY b_name
         ORDER BY 2 DESC;
      bname broker.b_name%TYPE;
      volume NUMBER;
      BEGIN
        DBMS_APPLICATION_INFO.SET_MODULE('Broker-Volume Query',NULL);
        init_info_array();
        OPEN curBrokerVolume;
        LOOP
          FETCH curBrokerVolume INTO bname, volume;
          EXIT WHEN curBrokerVolume%NOTFOUND;
        END LOOP;
        increment_selects(1);
        sleep(min_sleep, max_sleep);
        DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
        RETURN info_array;
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
            RAISE;
    END qryBrokerVolume;
    -----
    -- Function:    QryCustomerPosition
    -- Scope:       PUBLIC
    -- Purpose:     Performs three customer-centric queries:
    --              1.) Customer information
    --              2.) Customer's current asset balance
    --              3.) Customer's most recent trades
    -- Usage Notes: TPC-E Specification 3.3.2
    -----
    FUNCTION QryCustomerPosition(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array
    IS
      nFrame        NUMBER      := 0;
      nCustID       NUMBER      := 0;
      nCustTaxID    VARCHAR(12);
      CURSOR curCustomerInfo IS
        SELECT
             c_st_id
            ,c_l_name
            ,c_f_name
            ,c_m_name
            ,c_gndr
            ,c_tier
            ,c_dob
            ,c_ad_id
            ,c_ctry_1
            ,c_area_1
            ,c_local_1
            ,c_ext_1
            ,c_ctry_2
            ,c_area_2
            ,c_local_2
            ,c_ext_2
            ,c_ctry_3
            ,c_area_3
            ,c_local_3
            ,c_ext_3
            ,c_email_1
            ,c_email_2
          FROM customer
         WHERE c_id = nCustID;
      vc_c_st_id           customer.c_st_id%TYPE;
      vc_c_l_name          customer.c_l_name%TYPE;
      vc_c_f_name          customer.c_f_name%TYPE;
      vc_c_m_name          customer.c_m_name%TYPE;
      vc_c_gndr            customer.c_gndr%TYPE;
      n_c_tier             customer.c_tier%TYPE;
      dt_c_dob             customer.c_dob%TYPE;
      n_c_ad_id            customer.c_ad_id%TYPE;
      vc_c_ctry_1          customer.c_ctry_1%TYPE;
      vc_c_area_1          customer.c_area_1%TYPE;
      vc_c_local_1         customer.c_local_1%TYPE;
      vc_c_ext_1           customer.c_ext_1%TYPE;
      vc_c_ctry_2          customer.c_ctry_2%TYPE;
      vc_c_area_2          customer.c_area_2%TYPE;
      vc_c_local_2         customer.c_local_2%TYPE;
      vc_c_ext_2           customer.c_ext_2%TYPE;
      vc_c_ctry_3          customer.c_ctry_3%TYPE;
      vc_c_area_3          customer.c_area_3%TYPE;
      vc_c_local_3         customer.c_local_3%TYPE;
      vc_c_ext_3           customer.c_ext_3%TYPE;
      vc_c_email_1         customer.c_email_1%TYPE;
      vc_c_email_2         customer.c_email_2%TYPE;
      CURSOR curCustomerAssets IS
        SELECT
             ca_id AS acct_id
            ,ca_bal AS cash_bal
            ,NVL((SUM(HS_QTY * LT_PRICE)),0) AS assets_total
          FROM
             customer_account LEFT OUTER JOIN
             holding_summary ON hs_ca_id = ca_id
            ,last_trade
         WHERE ca_c_id = nCustID
           AND lt_s_symb = hs_s_symb
         GROUP BY ca_id, ca_bal
         ORDER BY 3 ASC
         FETCH FIRST 10 ROWS ONLY
         ;
      nCustAcctID         customer_account.ca_id%TYPE;
      nCustAcctBalance    customer_account.ca_bal%TYPE;
      nCustAcctTotAssets  NUMBER;
      CURSOR curCustomerTrades IS
        SELECT
             t_id
            ,t_s_symb
            ,t_qty
            ,st_name
            ,th_dts
            FROM
              (SELECT t_id AS id
                 FROM trade
                WHERE t_ca_id = nCustTaxID
                ORDER BY t_dts DESC
                FETCH FIRST 10 ROWS ONLY
              ) T
            ,trade
            ,trade_history
            ,status_type
         WHERE t_id = id
           AND th_t_id = t_id
           AND st_id = th_st_id
         ORDER BY th_dts DESC
         FETCH FIRST 30 ROWS ONLY
         ;
      nTradeID      trade.t_id%TYPE;
      vcSymbol      trade.t_s_symb%TYPE;
      nTradeQty     trade.t_qty%TYPE;
      vcStatusType  status_type.st_name%TYPE;
      tsTradeHist   trade_history.th_dts%TYPE;
    BEGIN
        DBMS_APPLICATION_INFO.SET_MODULE('Customer-Position Query',NULL);
        init_info_array();
        sleep(min_sleep, max_sleep);
        -----
        -- Select:
        -- 90% of time: a single Customer ID, or
        -- 10% of time: A Customer ID based on Customer Tax ID
        -----
        nFrame := DBMS_RANDOM.VALUE(0,9);
        If MOD(nFrame,9) = 0 THEN
          nCustTaxID := GetRandomCustomerTaxIdentifier;
        ELSE
          nCustID := GetRandomCustomerIdentifier;
        END IF;
        -----
        -- Frame 1
        -----
        OPEN curCustomerInfo;
        LOOP
          FETCH curCustomerInfo
           INTO
             vc_c_st_id
            ,vc_c_l_name
            ,vc_c_f_name
            ,vc_c_m_name
            ,vc_c_gndr
            ,n_c_tier
            ,dt_c_dob
            ,n_c_ad_id
            ,vc_c_ctry_1
            ,vc_c_area_1
            ,vc_c_local_1
            ,vc_c_ext_1
            ,vc_c_ctry_2
            ,vc_c_area_2
            ,vc_c_local_2
            ,vc_c_ext_2
            ,vc_c_ctry_3
            ,vc_c_area_3
            ,vc_c_local_3
            ,vc_c_ext_3
            ,vc_c_email_1
            ,vc_c_email_2;
          EXIT WHEN curCustomerInfo%NOTFOUND;
        END LOOP;
        CLOSE curCustomerInfo;
        -----
        -- Frame 2
        -- Should return between 1 to 10 rows
        -----
        OPEN curCustomerAssets;
        LOOP
          FETCH curCustomerAssets
           INTO
            nCustAcctID
           ,nCustAcctBalance
           ,nCustAcctTotAssets;
          EXIT WHEN curCustomerAssets%NOTFOUND;
        END LOOP;
        CLOSE curCustomerAssets;
        -----
        -- Frame 3
        -- Should return between 10 to 30 rows
        -----
        OPEN curCustomerTrades;
        LOOP
          FETCH curCustomerTrades
           INTO
            nTradeID
           ,vcSymbol
           ,nTradeQty
           ,vcStatusType
           ,tsTradeHist;
          EXIT WHEN curCustomerTrades%NOTFOUND;
        END LOOP;
        CLOSE curCustomerTrades;
        increment_selects(1);
        sleep(min_sleep, max_sleep);
        DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
        RETURN info_array;
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
            RAISE;
    END QryCustomerPosition;
    -----
    -- Function:    QryMarketWatch
    -- Scope:       PUBLIC
    -- Purpose:     Emulates the process of monitoring the overall performance
    --              of the market by allowing a customer to track the current daily
    --              trend (up or down) of a collection of securities. The collection
    --              of securities being monitored may be based upon a customer�s current
    --              holdings, a customer�s watch list of prospective securities, or a
    --              particular industry
    -- Usage Notes: TPC-E Specification 3.3.4
    -----
    FUNCTION QryMarketWatch(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array
    IS
        nCompanyID      company.co_id%TYPE;
        nBegCompanyID   company.co_id%TYPE;
        nEndCompanyID   company.co_id%TYPE;
        nCustID         customer.c_id%TYPE;
        nCustAcctID     customer_account.ca_id%TYPE;
        nOldPrice       daily_market.dm_close%TYPE := 0;
        dtStartDate     daily_market.dm_date%TYPE;
        vcIndustryName  industry.in_name%TYPE;
        nNewPrice       last_trade.lt_price%TYPE := 0;
        vcSymbol        security.s_symb%TYPE;
        nNbrShares      security.s_num_out%TYPE := 0;
        nFrame          NUMBER      := 0;
        nOldMktCap      NUMBER      := 0;
        nNewMktCap      NUMBER      := 0;
        nPctChange      NUMBER      := 0;
        TYPE typSymbList
          IS TABLE OF SECURITY.s_symb%TYPE
          INDEX BY PLS_INTEGER;
        colSymbList     typSymbList;
        CURSOR curWatchListSymbols IS
          SELECT wi_s_symb AS vcSymbol
            FROM
               watch_item
              ,watch_list
           WHERE wi_wl_id = wl_id
             AND wl_c_id = nCustID;
        CURSOR curIndustrySymbols IS
          SELECT s_symb AS vcSymbol
            FROM
               industry
              ,company
              ,security
           WHERE in_name = vcIndustryName
             AND co_in_id = in_id
             AND co_id BETWEEN nBegCompanyID AND nEndCompanyID
             AND s_co_id = nCompanyId;
        CURSOR curHoldingSummarySymbols IS
          SELECT hs_s_symb AS vcSymbol
            FROM holding_summary
           WHERE hs_ca_id = nCustAcctID;
    BEGIN
        DBMS_APPLICATION_INFO.SET_MODULE('Market Watch Query',NULL);
        init_info_array();
        sleep(min_sleep, max_sleep);
        nFrame := ROUND(DBMS_RANDOM.VALUE(1,9),0);
        CASE
            WHEN nFrame IN (1,3,5) THEN
              -----
              -- Frame 1:
              -- Build list of stocks from WATCH LIST tabel for a random Customer
              -----
              BEGIN
                nCustID := GetRandomCustomerIdentifier;
                OPEN  curWatchListSymbols;
                FETCH curWatchListSymbols BULK COLLECT INTO colSymbList;
                CLOSE curWatchListSymbols;
                /*
                OPEN curWatchListSymbols;
                LOOP
                  FETCH curWatchListSymbols INTO colSymbList;
                  EXIT WHEN curWatchListSymbols%NOTFOUND;
                END LOOP;
                CLOSE curWatchListSymbols;
                */
              END;
            WHEN nFrame IN (2,4,6) THEN
              -----
              -- Frame 2:
              -- Build list of stocks from SECURITY table based on a randomly-
              -- selected Industry for a randomly-selected Company
              -----
              BEGIN
                nCompanyID := GetRandomCompanyIdentifier;
                vcIndustryName := GetRandomIndustryName;
                nBegCompanyId := (nCompanyID - ROUND(DBMS_RANDOM.VALUE(10,100),0));
                nEndCompanyId := (nBegCompanyID + ROUND(DBMS_RANDOM.VALUE(10,100),0));
                OPEN  curIndustrySymbols;
                FETCH curIndustrySymbols BULK COLLECT INTO colSymbList;
                CLOSE curIndustrySymbols;
              END;
            ELSE
              -----
              -- Frame 3:
              -- Build list of stocks from HOLDING_SUMMARY table based on a
              -- randomly-selected Customer Account ID
              -----
              BEGIN
                nCustAcctID := GetRandomCustomerAccountIdentifier;
                OPEN  curHoldingSummarySymbols;
                FETCH curHoldingSummarySymbols BULK COLLECT INTO colSymbList;
                CLOSE curHoldingSummarySymbols;
              END;
        END CASE;
        -----
        -- If any Security symbols have been retrieved, calculate the overall
        -- percent change for those selected
        -----
        SELECT TO_DATE('2004-01-01','yyyy-mm-dd') - ROUND(DBMS_RANDOM.VALUE(365,1825),0)
          INTO dtStartDate
          FROM DUAL;
        FOR s IN 1 .. colSymbList.COUNT
          LOOP
            -- Get the Security's last traded price
            BEGIN
              SELECT lt_price
                INTO nNewPrice
                FROM last_trade
               WHERE lt_s_symb = colSymbList(s);
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                nNewPrice := 0;
            END;
            increment_selects(1);
            -- Get the Security's number of shares traded
            BEGIN
              SELECT s_num_out
                INTO nNbrShares
                FROM security
               WHERE s_symb = colSymbList(s);
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                nNbrShares := 0;
            END;
            increment_selects(1);
            -- Get the Security's daily market price for a random date
            -- (if it exists)
            BEGIN
              SELECT dm_close
                INTO nOldPrice
                FROM daily_market
               WHERE dm_s_symb = colSymbList(s)
                 AND dm_date = dtStartDate;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                nOldPrice := 0;
            END;
            increment_selects(1);
            -----
            -- Calculate market capitalization:
            -----
            nOldMktCap := 0.0;
            nNewMktCap := 0.0;
            nPctChange := 0.0;
            nOldMktCap := nOldMktCap + (nNbrShares * nOldPrice);
            nNewMktCap := nNewMktCap + (nNbrShares * nNewPrice);
            IF (nOldMktCap != 0) THEN
              nPctChange := 100 * (nNewMktCap / nOldMktCap - 1);
            ELSE
              nPctChange := 0;
            END IF;
          END LOOP;
        sleep(min_sleep, max_sleep);
        DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
        RETURN info_array;
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('QryMarketWatch Frame #' || nFrame || ' failed!');
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
            RAISE;
    END QryMarketWatch;
    -----
    -- Function:    QrySecurityDetail
    -- Scope:       PUBLIC
    -- Purpose:     Emulates the process of capturing detailed information for a
    --              particular Security, similar to the way in which a customer
    --              would research a security prior to deciding whether or not to
    --              execute a trade
    -- Usage Notes: TPC-E Specification 3.3.5
    -----
    FUNCTION QrySecurityDetail(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array
    IS
      nCompanyID            company.co_id%TYPE;
      vcSymbol              security.s_symb%TYPE;
      vcAddrLine1           address.ad_line1%TYPE;
      vcAddrLine2           address.ad_line2%TYPE;
      vcZipCode             zip_code.zc_code%TYPE;
      vcZipTown             zip_code.zc_town%TYPE;
      vcZipDiv              zip_code.zc_div%TYPE;
      vcAddrCountry         address.ad_ctry%TYPE;
      vcCompanyName         company.co_name%TYPE;
      vcCompanyStatus       company.co_st_id%TYPE;
      vcCompanyRate         company.co_sp_rate%TYPE;
      vcCompanyCEO          company.co_ceo%TYPE;
      vcCompanyDesc         company.co_desc%TYPE;
      dtCompanyOpen         company.co_open_date%TYPE;
      nExchgClose           exchange.ex_close%TYPE;
      vcExchgDesc           exchange.ex_desc%TYPE;
      vcExchgName           exchange.ex_name%TYPE;
      nExchgNbrSymbol       exchange.ex_num_symb%TYPE;
      nExchgOpen            exchange.ex_open%TYPE;
      vcSecName             security.s_name%TYPE;
      nSecNumOut            security.s_num_out%TYPE;
      dtSecStart            security.s_start_date%TYPE;
      nSecPE                security.s_pe%TYPE;
      nSec52wkHigh          security.s_52wk_high%TYPE;
      dtSec52wkHigh         security.s_52wk_high_date%TYPE;
      nSec52wkLow           security.s_52wk_low%TYPE;
      dtSec52wkLow          security.s_52wk_low_date%TYPE;
      nSecDividend          security.s_dividend%TYPE;
      nSecYield             security.s_yield%TYPE;
      vcIndustryName        industry.in_name%TYPE;
      nFinYear              financial.fi_year%TYPE;
      nFinQtr               financial.fi_qtr%TYPE;
      dtFinQtrStart         financial.fi_qtr_start_date%TYPE;
      nFinRevenue           financial.fi_revenue%TYPE;
      nFinNetEarnings       financial.fi_net_earn%TYPE;
      nFinBasicEPS          financial.fi_basic_eps%TYPE;
      nFinDilutedEPS        financial.fi_dilut_eps%TYPE;
      nFinMargin            financial.fi_margin%TYPE;
      nFinInventory         financial.fi_inventory%TYPE;
      nFinAssets            financial.fi_assets%TYPE;
      nFinLiability         financial.fi_liability%TYPE;
      nFinOutBasic          financial.fi_out_basic%TYPE;
      nFinOutDiluted        financial.fi_out_dilut%TYPE;
      dtDlyMkt              daily_market.dm_date%TYPE;
      nDlyMktClose          daily_market.dm_close%TYPE;
      nDlyMktHigh           daily_market.dm_high%TYPE;
      nDlyMktLow            daily_market.dm_low%TYPE;
      nDlyMktVolume         daily_market.dm_vol%TYPE;
      nLastTradeprice       last_trade.lt_price%TYPE;
      nLastTradeOpenPrice   last_trade.lt_open_price%TYPE;
      nLastTradeVolume      last_trade.lt_vol%TYPE;
      vcNewsItemHeadline    news_item.ni_headline%TYPE;
      vcNewsItemSummary     news_item.ni_summary%TYPE;
      lobNewsItem           news_item.ni_item%TYPE;
      tsNewsItem            news_item.ni_dts%TYPE;
      vcNewsItemSource      news_item.ni_source%TYPE;
      vcNewsItemAuthor      news_item.ni_author%TYPE;
      CURSOR curCustSecDetails IS
        SELECT
             s_name
            ,co_id
            ,co_name
            ,co_sp_rate
            ,co_ceo
            ,co_desc
            ,co_open_date
            ,co_st_id
            ,CA.ad_line1
            ,CA.ad_line2
            ,ZCA.zc_town
            ,ZCA.zc_div
            ,CA.ad_zc_code
            ,CA.ad_ctry
            ,s_num_out
            ,s_start_date
            ,s_pe
            ,s_52wk_high
            ,s_52wk_high_date
            ,s_52wk_low
            ,s_52wk_low_date
            ,s_dividend
            ,s_yield
            ,EA.ad_line1
            ,EA.ad_line2
            ,ZEA.zc_town
            ,ZEA.zc_div
            ,EA.ad_zc_code
            ,EA.ad_ctry
            ,ex_close
            ,ex_desc
            ,ex_name
            ,ex_num_symb
            ,ex_open
          FROM
             security
            ,company
            ,address CA
            ,address EA
            ,zip_code ZCA
            ,zip_code ZEA
            ,exchange
        WHERE s_symb = vcSymbol
          AND co_id = s_co_id
          AND CA.ad_id = co_ad_id
          AND EA.ad_id = ex_ad_id
          AND ex_id = s_ex_id
          AND CA.ad_zc_code = ZCA.zc_code
          AND EA.ad_zc_code = ZEA.zc_code;
      CURSOR curCmpyIndustry IS
        SELECT
             co_name
            ,in_name
          FROM
             company_competitor
            ,company
            ,industry
         WHERE cp_co_id = co_id
           AND co_id = cp_comp_co_id
           AND in_id = cp_in_id
         FETCH FIRST 3 ROWS ONLY;
      CURSOR curCmpyFinancials IS
        SELECT
             fi_year
            ,fi_qtr
            ,fi_qtr_start_date
            ,fi_revenue
            ,fi_net_earn
            ,fi_basic_eps
            ,fi_dilut_eps
            ,fi_margin
            ,fi_inventory
            ,fi_assets
            ,fi_liability
            ,fi_out_basic
            ,fi_out_dilut
          FROM financial
         WHERE fi_co_id = nCompanyID
         ORDER BY fi_year ASC, fi_qtr
         FETCH FIRST 1 ROWS ONLY;
      CURSOR curDailyMarketDetails IS
        SELECT
             dm_date
            ,dm_close
            ,dm_high
            ,dm_low
            ,dm_vol
          FROM daily_market
         WHERE dm_s_symb = vcSymbol
           AND dm_date >= TO_DATE('1998-01-01','yyyy-mm-dd')
         ORDER BY dm_date ASC
         FETCH FIRST 1 ROWS ONLY;
      CURSOR curLastTrades IS
        SELECT
              lt_price
             ,lt_open_price
             ,lt_vol
          FROM last_trade
         WHERE lt_s_symb = vcSymbol
         FETCH FIRST 1 ROWS ONLY;
      CURSOR curCustNewsItems IS
        SELECT
             ni_item
            ,ni_dts
            ,ni_source
            ,ni_author
            ,ni_headline
            ,ni_summary
          FROM
             news_xref
            ,news_item
         WHERE ni_id = nx_ni_id
           AND nx_co_id = nCompanyID
         FETCH FIRST 1 ROWS ONLY;
      BEGIN
        DBMS_APPLICATION_INFO.SET_MODULE('Security Detail Query',null);
        init_info_array();
        vcSymbol := GetRandomSecuritySymbol;
        nCompanyID := GetRandomCompanyIdentifier;
        OPEN curCustSecDetails;
        LOOP
          FETCH curCustSecDetails
           INTO
             vcSecName
            ,nCompanyID
            ,vcCompanyName
            ,vcCompanyRate
            ,vcCompanyCEO
            ,vcCompanyDesc
            ,dtCompanyOpen
            ,vcCompanyStatus
            ,vcAddrLine1
            ,vcAddrLine2
            ,vcZipTown
            ,vcZipDiv
            ,vcZipCode
            ,vcAddrCountry
            ,nSecNumOut
            ,dtSecStart
            ,nSecPE
            ,nSec52wkHigh
            ,dtSec52wkHigh
            ,nSec52wkLow
            ,dtSec52wkLow
            ,nSecDividend
            ,nSecYield
            ,vcAddrLine1
            ,vcAddrLine2
            ,vcZipTown
            ,vcZipDiv
            ,vcZipCode
            ,vcAddrCountry
            ,nExchgClose
            ,vcExchgDesc
            ,vcExchgName
            ,nExchgNbrSymbol
            ,nExchgOpen;
          EXIT WHEN curCustSecDetails%NOTFOUND;
        END LOOP;
        CLOSE curCustSecDetails;
        increment_selects(1);
        OPEN curCmpyIndustry;
        LOOP
          FETCH curCmpyIndustry
          INTO
             vcCompanyName
            ,vcIndustryName;
          EXIT WHEN curCmpyIndustry%NOTFOUND;
        END LOOP;
        CLOSE curCmpyIndustry;
        OPEN curCmpyFinancials;
        LOOP
          FETCH curCmpyFinancials
          INTO
             nFinYear
            ,nFinQtr
            ,dtFinQtrStart
            ,nFinRevenue
            ,nFinNetEarnings
            ,nFinBasicEPS
            ,nFinDilutedEPS
            ,nFinMargin
            ,nFinInventory
            ,nFinAssets
            ,nFinLiability
            ,nFinOutBasic
            ,nFinOutDiluted;
          EXIT WHEN curCmpyFinancials%NOTFOUND;
        END LOOP;
        CLOSE curCmpyFinancials;
        increment_selects(1);
        OPEN curDailyMarketDetails;
        LOOP
          FETCH curDailyMarketDetails
          INTO
             dtDlyMkt
            ,nDlyMktClose
            ,nDlyMktHigh
            ,nDlyMktLow
            ,nDlyMktVolume;
          EXIT WHEN curDailyMarketDetails%NOTFOUND;
        END LOOP;
        CLOSE curDailyMarketDetails;
        increment_selects(1);
        OPEN curLastTrades;
        LOOP
          FETCH curLastTrades
           INTO
              nLastTradeprice
             ,nLastTradeOpenPrice
             ,nLastTradeVolume;
          EXIT WHEN curLastTrades%NOTFOUND;
        END LOOP;
        CLOSE curLastTrades;
        increment_selects(1);
        OPEN curCustNewsItems;
        LOOP
          FETCH curCustNewsItems
           INTO
             lobNewsItem
            ,tsNewsItem
            ,vcNewsItemSource
            ,vcNewsItemAuthor
            ,vcNewsItemHeadline
            ,vcNewsItemSummary;
          EXIT WHEN curCustNewsItems%NOTFOUND;
        END LOOP;
        CLOSE curCustNewsItems;
        increment_selects(1);
        sleep(min_sleep, max_sleep);
        DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
        RETURN info_array;
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
          RAISE;
    END QrySecurityDetail;
    ----
    -- Function:    QryTradeLookup
    -- Scope:       PUBLIC
    -- Purpose:     Simulates retrieval of data by either a Customer or a
    --              Broker to satisfy questions on a set of trades. This
    --              process will choose between one of four representative
    --              scenarios:
    --              (a) performing general market analysis; or
    --              (b) reviewing trades for a period of time prior to the most
    --                  recent account statement; or
    --              (c) analyzing past performance of a particular security; or
    --              (d) analyzing the history of a particular customer holding
    -- Usage Notes: TPC-E Specification 3.3.6
    -----
    FUNCTION QryTradeLookup(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array
    IS
      -----
      -- Control variables:
      -----
      nFrame            NUMBER := 0;
      nMaxTrades        NUMBER := 0;
      nRowsRetrieved    INTEGER := 0;
      vcCashDesc        cash_transaction.ct_name%TYPE;
      nCashAmt          cash_transaction.ct_amt%TYPE;
      tsCash            cash_transaction.ct_dts%TYPE;
      nSettleAmt        settlement.se_amt%TYPE;
      vcSettleCashType  settlement.se_cash_type%TYPE;
      dtSettleDue       settlement.se_cash_due_date%TYPE;
      nTradeID          trade.t_id%TYPE;
      nMinTradeID       trade.t_id%TYPE;
      nMaxTradeID       trade.t_id%TYPE;
      nCustAcctID       trade.t_ca_id%TYPE;
      nMaxAcctID        trade.t_ca_id%TYPE;
      bIsCash           trade.t_is_cash%TYPE;
      nTradeTypeID      trade.t_tt_id%TYPE;
      vcTradeExecName   trade.t_exec_name%TYPE;
      vcSymbol          trade.t_s_symb%TYPE;
      tsTrade           trade.t_dts%TYPE;
      tsTradeBeg        trade.t_dts%TYPE;
      tsTradeEnd        trade.t_dts%TYPE;
      nTradePrice       trade.t_trade_price%TYPE;
      nTradeBidPrice    trade.t_bid_price%TYPE;
      nOrigTradeQty     trade.t_qty%TYPE;
      nTradeQty         trade.t_qty%TYPE;
      tsTradeHistTime   trade_history.th_dts%TYPE;
      bIsMrkt           trade_type.tt_is_mrkt%TYPE;
      CURSOR curTradesByID IS
        SELECT t_id
            FROM (SELECT t_id
                    FROM trade
                   WHERE t_id BETWEEN nMinTradeID AND nMaxTradeID
                   ORDER BY t_id ASC)
         WHERE ROWNUM <= nMaxTrades;
      CURSOR curTradesByCustAcct IS
        SELECT t_id
          FROM (SELECT t_id
                  FROM trade
                 WHERE t_ca_id = nCustAcctID
                   AND t_dts >= tsTradeBeg
                   AND t_dts <= tsTradeEnd
                  ORDER BY t_dts ASC)
         WHERE ROWNUM <= nMaxTrades;
      CURSOR curTradesBySymbol IS
        SELECT t_id
          FROM (SELECT t_id
                  FROM trade
                 WHERE t_s_symb = vcSymbol
                   AND t_dts >= tsTradeBeg
                   AND t_dts <= tsTradeEnd
                   AND t_ca_id <= nMaxAcctID)
         WHERE ROWNUM <= nMaxTrades;
      CURSOR curTradesByDate IS
        SELECT t_id
          FROM trade
         WHERE t_ca_id = nCustAcctID
           AND t_dts >= tsTradeBeg
         ORDER BY t_dts ASC
         FETCH FIRST 1 ROW ONLY;
      TYPE recHoldingHistoryFirstTwenty
        IS RECORD (
            nOrigTradeID      holding_history.hh_h_t_id%TYPE
           ,nNewTradeID       holding_history.hh_t_id%TYPE
           ,nOrigTradeQty     holding_history.hh_before_qty%TYPE
           ,nNewTradeQty      holding_history.hh_after_qty%TYPE
      );
      CURSOR curHoldingHistoryFirstTwenty
        RETURN recHoldingHistoryFirstTwenty
      IS
        SELECT
             hh_h_t_id
            ,hh_t_id
            ,hh_before_qty
            ,hh_after_qty
          FROM holding_history
         WHERE hh_h_t_id = nTradeID
        FETCH FIRST 20 ROWS ONLY;
      FirstTwentyHoldings   recHoldingHistoryFirstTwenty;
    BEGIN
        DBMS_APPLICATION_INFO.SET_MODULE('Trade Lookup Query',null);
        init_info_array();
        sleep(min_sleep, max_sleep);
        -----
        -- Choose at random:
        -- 1.) Which frame to execute (1-4)
        -- 2.) The maximum number of Trades to retrieve (1-20)
        -----
        nFrame      := ROUND(DBMS_RANDOM.VALUE(1,10),0);
        nMaxTrades  := ROUND(DBMS_RANDOM.VALUE(1,20),0);
        CASE
            WHEN nFrame IN (1,3,5) THEN
            -----
            -- Frame 1: 30%
            -- Retrieve and return information about the selected set of Trades
            -----
            BEGIN
              nMinTradeID := ROUND(DBMS_RANDOM.VALUE(MIN_TRADE_ID,MAX_TRADE_ID),0);
              nMaxTradeID := nMinTradeID + 100;
              OPEN curTradesByID;
              LOOP
                FETCH curTradesByID INTO nTradeID;
                EXIT WHEN curTradesByID%NOTFOUND;
                -----
                -- Retrieve Trade pricing attributes
                -----
                  SELECT
                       t_bid_price
                      ,t_exec_name
                      ,t_is_cash
                      ,tt_is_mrkt
                      ,t_trade_price
                    INTO
                       nTradeBidPrice
                      ,vcTradeExecName
                      ,bIsCash
                      ,bIsMrkt
                      ,nTradePrice
                    FROM
                       trade
                      ,trade_type
                   WHERE t_tt_id = tt_id
                     AND t_id = nTradeID;
                  increment_selects(1);
                  -----
                  -- Retrieve Settlement information for each Trade
                  -----
                  SELECT
                       se_amt
                      ,se_cash_due_date
                      ,se_cash_type
                    INTO
                       nSettleAmt
                      ,dtSettleDue
                      ,vcSettleCashType
                    FROM settlement
                   WHERE se_t_id = nTradeID;
                  increment_selects(1);
                  -----
                  -- If this is a cash transaction, get corresponding information
                  -----
                  IF (bIsCash = 1) THEN
                    SELECT
                         ct_amt
                        ,ct_dts
                        ,ct_name
                      INTO
                         nCashAmt
                        ,tsCash
                        ,vcCashDesc
                      FROM cash_transaction
                     WHERE ct_t_id = nTradeID;
                    increment_selects(1);
                  END IF;
                  -----
                  -- Retrieve Trade History information for the selected Trade, limiting
                  -- retrieval to a maximum of three (3) rows
                  -----
                  SELECT MAX(th_dts)
                    INTO tsTradeHistTime
                    FROM (SELECT
                               th_dts
                              ,th_st_id
                    FROM trade_history
                   WHERE th_t_id = nTradeID
                  ORDER BY th_dts ASC
                  FETCH FIRST 3 ROWS ONLY);
                  increment_selects(1);
                END LOOP;
              CLOSE curTradesByID;
            END;
          WHEN nFrame IN (2,4,6) THEN
            -----
            -- Frame 2: 30%
            -- Retrieve and return information about the first N Trades for a
            -- specific Customer Account as of a specific point in time
            -----
            BEGIN
              nCustAcctID := GetRandomCustomerAccountIdentifier;
              OPEN curTradesByCustAcct;
              LOOP
                FETCH curTradesByCustAcct INTO nTradeID;
                EXIT WHEN curTradesByCustAcct%NOTFOUND;
                BEGIN
                  SELECT
                       t_bid_price
                      ,t_exec_name
                      ,t_is_cash
                      ,t_id
                      ,t_trade_price
                    INTO
                       nTradeBidPrice
                      ,vcTradeExecName
                      ,bIsCash
                      ,nTradeID
                      ,nTradePrice
                    FROM trade
                   WHERE t_id = nTradeID;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      RAISE;
                END;
              END LOOP;
              CLOSE curTradesByCustAcct;
            END;
          WHEN nFrame IN (7,8,9) THEN
            -----
            -- Frame 3: 30%
            -- Retrieve and return a list of N trades executed for the selected
            -- Security starting at a specified point in time
            -----
            BEGIN
              vcSymbol    := GetRandomSecuritySymbol;
              tsTradeEnd  := TO_DATE('2005-12-31', 'yyyy-mm-dd') + ROUND(DBMS_RANDOM.VALUE(1,365),0);
              tsTradeBeg  := tsTradeEnd - ROUND(DBMS_RANDOM.VALUE(180,540),0);
              nMaxAcctID  := GetRandomCustomerAccountIdentifier;
              OPEN  curTradesBySymbol;
              LOOP
                FETCH curTradesBySymbol INTO nTradeID;
                EXIT WHEN curTradesBySymbol%NOTFOUND;
                BEGIN
                -- Get Trade information
                SELECT
                     t_ca_id
                    ,t_exec_name
                    ,t_is_cash
                    ,t_trade_price
                    ,t_qty
                    ,t_dts
                    ,t_id
                    ,t_tt_id
                  INTO
                     nCustAcctID
                    ,vcTradeExecName
                    ,bIsCash
                    ,nTradePrice
                    ,nTradeQty
                    ,tsTrade
                    ,nTradeID
                    ,nTradeTypeID
                  FROM trade
                 WHERE t_id = nTradeID;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    RAISE;
                END;
              END LOOP;
              CLOSE curTradesBySymbol;
          END;
          ELSE
            -----
            -- Frame 4: 10%
            -- Retrieve and return information from HOLDING_HISTORY for the specified
            -- set of Trade IDs
            -----
            BEGIN
              -----
              -- Retrieve first 50 Trades and related Trade information
              -- for the randomly-selected Customer Account ID
              -----
              nCustAcctID := GetRandomCustomerAccountIdentifier;
              tsTradeBeg  := TO_DATE('2005-12-31', 'yyyy-mm-dd') - ROUND(DBMS_RANDOM.VALUE(180,540),0);
              OPEN curTradesByDate;
              LOOP
                FETCH curTradesByDate INTO nTradeID;
                EXIT WHEN curTradesByDate%NOTFOUND;
                  -----
                  -- The trade_id is used in the subquery to find the original trade_id
                  -- (HH_H_T_ID), which then is used to list all the entries.
                  -- Should return 0 to (capped) 20 rows.
                  -----
                  OPEN curHoldingHistoryFirstTwenty;
                  LOOP
                    FETCH curHoldingHistoryFirstTwenty INTO FirstTwentyHoldings;
                    EXIT WHEN curHoldingHistoryFirstTwenty%NOTFOUND;
                    nRowsRetrieved := nRowsRetrieved + 1;
                  END LOOP;
                  CLOSE curHoldingHistoryFirstTwenty;
                  increment_selects(1);
              END LOOP;
              CLOSE curTradesByDate;
            EXCEPTION
              WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('QryTradeLookup Frame #4 unexplained failure!');
                RAISE;
            -- End of Frame 4
            END;
        END CASE;
        sleep(min_sleep, max_sleep);
        increment_selects(1);
        DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
        RETURN info_array;
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
            RAISE;
    END QryTradeLookup;
    -----
    -- Function:    QryTradeStatus
    -- Scope:       PUBLIC
    -- Purpose:     Performs retrieval of Trade-related information from several
    --              TPC-E tables based on a randomly-selected Customer Account ID
    --              to simulate a customer-initiated request for the status
    --              of their Trades
    -- Usage Notes: TPC-E Specification 3.3.9
    -----
    FUNCTION QryTradeStatus(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array
    IS
      nCustAcctID       customer_account.ca_id%TYPE;
      nRowsRetrieved    INTEGER := 0;
      TYPE recTradesFirstFifty
        IS RECORD (
            nTradeID          trade.t_id%TYPE
           ,tsTrade           trade.t_dts%TYPE
           ,vcStatType        status_type.st_name%TYPE
           ,vcTradeType       trade_type.tt_name%TYPE
           ,vcSymbol          trade.t_s_symb%TYPE
           ,nTradeQty         trade.t_qty%TYPE
           ,vcTradeExec       trade.t_exec_name%TYPE
           ,nChrgAmt          trade.t_chrg%TYPE
           ,vcSecName         security.s_name%TYPE
           ,vcExchgName       exchange.ex_name%TYPE
      );
      CURSOR curTradesFirstFifty
        RETURN recTradesFirstFifty
      IS
        SELECT
             t_id
            ,t_dts
            ,st_name
            ,tt_name
            ,t_s_symb
            ,t_qty
            ,t_exec_name
            ,t_chrg
            ,s_name
            ,ex_name
          FROM
             trade
            ,status_type
            ,trade_type
            ,security
            ,exchange
         WHERE t_ca_id = nCustAcctID
           AND st_id = t_st_id
           AND tt_id = t_tt_id
           AND s_symb = t_s_symb
           AND ex_id = s_ex_id
         ORDER BY t_dts DESC
         FETCH FIRST 50 ROWS ONLY;
      FirstFiftyTrades recTradesFirstFifty;
      TYPE recBrokerCustAcctInfo
        IS RECORD (
             vcCustLastName     customer.c_l_name%TYPE
            ,vcCustFirstName    customer.c_f_name%TYPE
            ,vcBrokerName       broker.b_name%TYPE
      );
      CURSOR curBrokerCustAcctInfo
        RETURN recBrokerCustAcctInfo
      IS
        SELECT
             c_l_name
            ,c_f_name
            ,b_name
         FROM
            customer_account
           ,customer
           ,broker
         WHERE ca_id = nCustAcctID
           and c_id = ca_c_id
           AND b_id = ca_b_id;
      BrokerCustAcctInfo  recBrokerCustAcctInfo;
    BEGIN
        DBMS_APPLICATION_INFO.SET_MODULE('Trade Status Query',null);
        init_info_array();
        sleep(min_sleep, max_sleep);
        -----
        -- Choose a Customer Account ID at random
        -----
        nCustAcctID := GetRandomCustomerAccountIdentifier;
        -----
        -- Retrieve first 50 Trades and related Trade information
        -- for the randomly-selected Customer Account ID
        -----
        OPEN curTradesFirstFifty;
        LOOP
          FETCH curTradesFirstFifty INTO FirstFiftyTrades;
          EXIT WHEN curTradesFirstFifty%NOTFOUND;
          nRowsRetrieved := nRowsRetrieved + 1;
        END LOOP;
        CLOSE curTradesFirstFifty;
        increment_selects(1);
        -----
        -- Retrieve related Customer and Broker information for
        -- the randomly-selected Customer Account ID
        -----
        OPEN curBrokerCustAcctInfo;
        LOOP
          FETCH curBrokerCustAcctInfo INTO BrokerCustAcctInfo;
          EXIT WHEN curBrokerCustAcctInfo%NOTFOUND;
          nRowsRetrieved := nRowsRetrieved + 1;
        END LOOP;
        CLOSE curBrokerCustAcctInfo;
        increment_selects(1);
        increment_rows_selected(nRowsRetrieved);
        sleep(min_sleep, max_sleep);
        DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
        RETURN info_array;
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
            RAISE;
    END QryTradeStatus;
    /*
    || Maintenance Transactions:
    */
    -----
    -- Function:    MntMarketFeed
    -- Scope:       PUBLIC
    -- Purpose:     Emulates the process of tracking the current market activity.
    --              This is representative of the brokerage house processing the
    --              �ticker-tape� from the market exchange.
    -- Usage Notes: TPC-E Specification 3.3.3
    -----
    FUNCTION MntMarketFeed(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array
    IS
      tsMktSubmit     last_trade.lt_dts%TYPE;
      nTradeID        trade_request.tr_t_id%TYPE;
      nBidPrice       trade_request.tr_bid_price%TYPE;
      vcTradeType     trade_request.tr_tt_id%TYPE;
      nTradeQty       trade_request.tr_qty%TYPE;
      vcSymbol        trade_request.tr_s_symb%TYPE;
      nPriceQuote     trade_request.tr_bid_price%TYPE := 0;
      CycleBackLater  EXCEPTION;
      TYPE typTradeID
        IS TABLE OF TRADE_REQUEST.tr_t_id%TYPE
        INDEX BY PLS_INTEGER;
      colTradeID     typTradeID;
      TYPE typTradeTypeID
        IS TABLE OF TRADE_REQUEST.tr_tt_id%TYPE
        INDEX BY PLS_INTEGER;
      colTradeTypeID typTradeTypeID;
      TYPE typTradeQty
        IS TABLE OF TRADE_REQUEST.tr_qty%TYPE
        INDEX BY PLS_INTEGER;
      colTradeQty      typTradeQty;
      TYPE typBidPrice
        IS TABLE OF TRADE_REQUEST.tr_bid_price%TYPE
        INDEX BY PLS_INTEGER;
      colBidPrice    typBidPrice;
      CURSOR curRequestList IS
        WITH
          curPENDING AS(
          SELECT
               lt_s_symb AS vcSymbol
              ,ROUND(MAX(lt_open_price) * (1 + (DBMS_RANDOM.VALUE(-0.15,0.15))),2) as nPriceQuote
            FROM last_trade
           WHERE lt_s_symb IN (
            SELECT tr_s_symb FROM (
              SELECT tr_s_symb, SUM(tr_qty)
                FROM trade_request
               GROUP BY tr_s_symb
               ORDER BY 2 DESC
               FETCH FIRST 10 ROWS ONLY))
           GROUP BY lt_s_symb)
        SELECT
             tr_t_id
            ,tr_bid_price
            ,tr_tt_id
            ,tr_qty
          FROM trade_request, curPending
        WHERE tr_s_symb = curpending.vcSymbol
          AND (
              (tr_tt_id = 'TSL' AND tr_bid_price >= curpending.nPriceQuote)
           OR (tr_tt_id = 'TLS' AND tr_bid_price <= curpending.nPriceQuote)
           OR (tr_tt_id = 'TLB' AND tr_bid_price >= curpending.nPriceQuote)
            );
    BEGIN
        DBMS_APPLICATION_INFO.SET_MODULE('Market Feed Transaction',NULL);
        init_info_array();
        sleep(min_sleep, max_sleep);
        tsMktSubmit :=
          TO_TIMESTAMP((DFLT_TRADE_DATE || '.' ||ROUND(DBMS_RANDOM.VALUE(10,12),0) || ':' ||
                ROUND(DBMS_RANDOM.VALUE(10,59),0) || ':' || ROUND(DBMS_RANDOM.VALUE(10,59),0)),
                'YYYY-MM-DD.HH24:MI:SS');
        -----
        -- For a list of 10 Securities that comprise the Trades in PNDG
        -- status, ordered by descending quantity traded per Security,
        -- from the TRADE_REQUEST table, calculate a theoretical price for each
        -- Security that has been derived for a more realistic treatment
        -- within a busy market exchange. Then find all pending Trades in
        -- TRADE_REQUEST that meet the requirements for executing a Limit trade
        -- based on the simulated generated per-share price
        -----
        OPEN curRequestList;
        FETCH curRequestList BULK COLLECT INTO colTradeID, colBidPrice, colTradeTypeID, colTradeQty;
        CLOSE curRequestList;
        FOR t IN 1 .. colTradeID.COUNT
          LOOP
            nTradeID    := colTradeID(t);
            nBidPrice   := colBidPrice(t);
            vcTradeType := colTradeTypeID(t);
            nTradeQty   := colTradeQty(t);
            -----
            -- 1.) Update the total holdings and pricing for the selected
            --     Security in LAST_TRADE as of the processing timestamp
            -----
            UPDATE last_trade
               SET
                lt_price = nBidPrice
               ,lt_vol = lt_vol + nTradeQty
               ,lt_dts = tsMktSubmit
             WHERE lt_s_symb = vcSymbol;
            increment_updates(1);
            -----
            -- 2.) Change the Trade's status to Submitted
            -----
            UPDATE trade
               SET
                t_dts = tsMktSubmit
               ,t_st_id = 'SBMT'
             WHERE t_id = nTradeID;
            increment_updates(1);
            -----
            -- 3.) Remove the completed Pending Trade from TRADE_REQUEST
            -----
            DELETE trade_request
             WHERE tr_t_id = nTradeID;
            increment_deletes(1);
            -----
            -- 4.) Add the successfully-completed Trade into TRADE_HISTORY
            -----
            BEGIN
              INSERT INTO trade_history (
                   th_t_id
                  ,th_dts
                  ,th_st_id
              )
              VALUES (
                   nTradeId
                  ,tsMktSubmit
                  ,'SBMT'
              );
              increment_inserts(1);
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                  DBMS_OUTPUT.PUT_LINE('>> Market Feed: Trade Submission: TH_T_ID: ' || nTradeID || ' TH_ST_ID: ' || 'SBMT');
              RAISE CycleBackLater;
            END;
            -----
            -- 5.) Commit these changes
            -----
            COMMIT;
            increment_commits(1);
            -----
            -- 6.) Submit this Trade for processing and settlement
            -----
            ProcessTradeResult(nTradeID);
          -- End of simulated Limit Market Execution loop
          END LOOP;
        sleep(min_sleep, max_sleep);
        DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
        RETURN info_array;
        EXCEPTION
          WHEN CycleBackLater THEN
            ROLLBACK;
            increment_rollbacks(1);
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
            RETURN info_array;
          WHEN OTHERS THEN
            ROLLBACK;
            increment_rollbacks(1);
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
            RAISE;
    END MntMarketFeed;
    -----
    -- Function:    MntTradeOrder
    -- Scope:       PUBLIC
    -- Purpose:     1.) Generates random Trade transactions for both Market-Order
    --                  and Limit-Order trading
    --              2.) Submits any Market-Order trades for immediate processing,
    --                  while marking any Limit-Order trades for later processing
    --                  as part of Market-Feed transactions
    -- Notes:       See TPC-E Specification Section 3.3.7
    -----
    FUNCTION MntTradeOrder(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array
    IS
        nFrame                NUMBER := 0;
        nBuyValue             NUMBER := 0;
        nSellValue            NUMBER := 0;
        nTaxableAmt           NUMBER := 0;
        nAcctAssets           NUMBER := 0;
        nAcctBalance          NUMBER := 0;
        nHeldAssets           NUMBER := 0;
        nRollItBack           NUMBER := 0;
        unverified_purchaser  EXCEPTION;
        nCustAcctID     customer_account.ca_id%TYPE := 0;
        vcAcctName      customer_account.ca_name%TYPE;
        nBrokerID       customer_account.ca_b_id%TYPE;
        nCustID         customer_account.ca_c_id%TYPE;
        nTaxStatus      customer_account.ca_tax_st%TYPE;
        vcCustFName     customer.c_f_name%TYPE;
        vcCustLName     customer.c_l_name%TYPE;
        nCustTier       customer.c_tier%TYPE;
        vcTaxID         customer.c_tax_id%TYPE;
        vcBrokerName    broker.b_name%TYPE;
        vcAcctPerm      account_permission.ap_acl%TYPE;
        nCompanyID      company.co_id%TYPE;
        vcCompanyName   company.co_name%TYPE;
        nExchgID        security.s_ex_id%TYPE;
        vcSymbol        security.s_symb%TYPE;
        vcSecName       security.s_name%TYPE;
        nLTPrice        last_trade.lt_price%TYPE := 0;
        vcTradeType     trade_type.tt_id%TYPE := 0;
        bAtMrkt         trade_type.tt_is_mrkt%TYPE := 0;
        bIsSale         trade_type.tt_is_sell%TYPE := 0;
        nRqstQty        trade.t_qty%TYPE := 0;
        nRqstPrice      trade.t_trade_price%TYPE := 0;
        nHeldPrice      trade.t_trade_price%TYPE := 0;
        nHeldQty        trade.t_qty%TYPE := 0;
        nHeldSmyQty     holding_summary.hs_qty%TYPE := 0;
        nNeededQty      trade.t_qty%TYPE := 0;
        nTaxRate        tax_rate.tx_rate%TYPE := 0;
        nCommRate       commission_rate.cr_rate%TYPE := 0;
        nChgRate        charge.ch_chrg%TYPE := 0;
        nNewTradeID     trade.t_id%TYPE;
        tsNewTrade      trade.t_dts%TYPE;
        vcTradeStatus   trade.t_st_id%TYPE;
        nCommAmt        trade.t_comm%TYPE;
        nChrgAmt        trade.t_chrg%TYPE;
        bIsCash         trade.t_is_cash%TYPE;
        bIsLIFO         trade.t_lifo%TYPE := 0;
        bIsMargin       trade.t_lifo%TYPE := 0;
        TYPE typHoldQty
          IS TABLE OF HOLDING.h_qty%TYPE
          INDEX BY PLS_INTEGER;
        colHoldQty      typHoldQty;
        TYPE typHoldPrice
          IS TABLE OF HOLDING.h_price%TYPE
          INDEX BY PLS_INTEGER;
        colHoldPrice    typHoldPrice;
          CURSOR curOldestHoldingsFirst IS
            SELECT h_qty, h_price
              FROM holding
             WHERE h_ca_id = nCustAcctID
               AND h_s_symb = vcSymbol
             ORDER BY h_dts ASC;
          CURSOR curNewestHoldingsFirst IS
            SELECT h_qty, h_price
              FROM holding
             WHERE h_ca_id = nCustAcctID
               AND h_s_symb = vcSymbol
             ORDER BY h_dts DESC;
    BEGIN
        DBMS_APPLICATION_INFO.SET_MODULE('Trade Order Transaction',NULL);
        init_info_array();
        sleep(min_sleep, max_sleep);
        -----
        -- Frame 1:
        -- 1.) Select a random Customer Account ID
        -- 2.) Generate a random requested quantity and price. Note that
        --     these are the main drivers for transaction processing and
        --     calculation of how much a single purchase transaction will
        --     require for payment, etc.)
        -- 3.) Get related account, customer, and broker information
        -----
        nCustAcctID := GetRandomCustomerAccountIdentifier;
        SELECT
             ca_name
            ,ca_b_id
            ,ca_c_id
            ,ca_tax_st
          INTO
             vcAcctName
            ,nBrokerID
            ,nCustID
            ,nTaxStatus
          FROM
            customer_account
         WHERE ca_id = nCustAcctID;
        SELECT
             c_f_name
            ,c_l_name
            ,c_tier
            ,c_tax_id
          INTO
            vcCustFName
           ,vcCustLName
           ,nCustTier
           ,vcTaxID
          FROM customer
         WHERE c_id = nCustID;
        SELECT b_name
          INTO vcBrokerName
          FROM broker
         WHERE b_id = nBrokerID;
        -----
        -- Frame 2:
        -- Verify that the person executing the trade has sufficient
        -- decision-making permissions to complete the specified trade action
        -- for the selected customer account. If not, the transaction ends immediately.
        -----
        SELECT ap_acl
          INTO vcAcctPerm
          FROM account_permission
         WHERE ap_ca_id = nCustAcctID
           AND ap_l_name = vcCustLName
           AND ap_tax_id = vcTaxID;
        IF vcAcctPerm IS NULL THEN
           RAISE unverified_purchaser;
        END IF;
        -----
        -- Frame 3:
        -- 1.) Determine a random Company ID and Exchange ID pair by searching
        --     the Security entity for either
        --     (a) 20%: A single random Security symbol; or
        --     (b) 80%: A random Security Issue for a particular Company
        -----
        nFrame := ROUND(DBMS_RANDOM.VALUE(1,5),0);
        IF (nFrame = 3) THEN
          BEGIN
            nCompanyID := GetRandomCompanyIdentifier;
            BEGIN
              SELECT
                   s_ex_id
                  ,s_name
                  ,s_symb
                INTO
                   nExchgID
                  ,vcSecName
                  ,vcSymbol
                FROM security
               WHERE s_co_id = nCompanyID
                 AND s_issue =
                   DECODE(ROUND(DBMS_RANDOM.VALUE(1,5),0)
                          ,1, 'COMMON'
                          ,2, 'PREF_A'
                          ,3, 'PREF_B'
                          ,4, 'PREF_C'
                            , 'PREF_D');
            EXCEPTION
              WHEN OTHERS THEN
                BEGIN
                  vcSymbol := GetRandomSecuritySymbol;
                  SELECT
                       s_name
                      ,s_ex_id
                    INTO
                       vcSecName
                      ,nExchgID
                    FROM security
                   WHERE s_symb = vcSymbol;
                END;
            END;
          END;
        ELSE
          BEGIN
            vcSymbol := GetRandomSecuritySymbol;
            SELECT
                 s_co_id
                ,s_ex_id
                ,s_name
              INTO
                 nCompanyID
                ,nExchgID
                ,vcSecName
              FROM security
             WHERE s_symb = vcSymbol;
            SELECT co_name
              INTO vcCompanyName
              FROM company
             WHERE co_id = nCompanyID;
          END;
        END IF;
        -----
        -- Get current price for the security
        -----
        SELECT lt_price
          INTO nLTPrice
          FROM last_trade
         WHERE lt_s_symb = vcSymbol;
        -----
        -- 1.) Choose a random Trade Type
        -- 2.) Set trade characteristics based on the type of trade
        --
        -- Trade               Sell/    At
        -- Code   Trade Type   Buy?     Market?
        -- -----  -----------  -------  -------
        -- TMS    Market-Sell  1 (yes)  1 (yes)
        -- TSL    Stop-Loss    1 (yes)  0 (no)
        -- TLS    Limit-Sell   1 (yes)  0 (no)
        -- TMB    Market-Buy   0 (no)   1 (yes)
        -- TLB    Limit-Buy    0 (no)   0 (no)
        -----
        vcTradeType := trtypes(ROUND(DBMS_RANDOM.VALUE(1,5),0));
        SELECT
             tt_is_sell
            ,tt_is_mrkt
          INTO
             bIsSale
            ,bAtMrkt
          FROM trade_type
         WHERE tt_id = vcTradeType;
        -----
        -- Generate a random quantity for the Security to be purchased
        -----
        nRqstQty := ROUND(DBMS_RANDOM.VALUE(MIN_RQST_QTY, MAX_RQST_QTY),2);
        -----
        -- Limit-Order vs. Market Order Pricing:
        -- 1.) Market Orders use the current market price for the selected Security from LAST_TRADE
        -- 2.) Limit Orders use a randomized price that is between -10% and + 10% of the current
        --     market price for the selected Security
        -----
        IF (bAtMrkt = 0) THEN
          nRQSTPrice := nLTPrice;
        ELSE
          nRQSTPrice := nLTPrice * (1 + (ROUND(DBMS_RANDOM.VALUE(-10,10),2) / 100));
        END IF;
        -----
        -- Gather current holding quantiites for the selected Security for the
        -- selected Customer's Account; if none exist, then set the current holding
        -- quantity to zero (0)
        -----
        nBuyValue     := 0;
        nSellValue    := 0;
        nNeededQty    := nRqstQty;
        BEGIN
          SELECT hs_qty
            INTO nHeldSmyQty
            FROM holding_summary
           WHERE hs_ca_id = nCustAcctID
             AND hs_s_symb = vcSymbol;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            nHeldSmyQty := 0;
        END;
        -----
        -- Determine if this is a SELL or BUY transaction
        -----
        IF (bIsSale = 1) THEN
          -----
          -- This is a Sale, so determine if there are any
          -- existing holdings for the Security to be sold
          -----
          IF (nHeldSmyQty > 0) THEN
            -----
            -- There are existing holdings, so now decide [randomly, on a 50/50 basis]
            -- in what fashion these existing holdings will be processed - either in:
            -- LIFO (Last-In, First-Out) order, i.e. newest-to-oldest; or
            -- FIFO (First-In, First-Out) order, i.e. oldest-to-newest order
            -----
            IF (ROUND(DBMS_RANDOM.VALUE(1,100),0) <= 35) THEN
              bIsLIFO := 1;
            ELSE
              bIsLIFO := 0;
            END IF;
            IF (bIsLIFO = 1) THEN
              -- LIFO
              OPEN  curNewestHoldingsFirst;
              FETCH curNewestHoldingsFirst BULK COLLECT INTO colHoldQty, colHoldPrice;
              CLOSE curNewestHoldingsFirst;
            ELSE
              -- FIFO
              OPEN curOldestHoldingsFirst;
              FETCH curOldestHoldingsFirst BULK COLLECT INTO colHoldQty, colHoldPrice;
              CLOSE curOldestHoldingsFirst;
            END IF;
            -----
            -- Estimate, based on the requested price, any profit that may be realized
            -- by selling current holdings for this security. The customer may have
            -- multiple holdings at different prices for this security (representing
            -- multiple purchases different times).
            -----
            FOR h IN 1 .. colHoldQty.COUNT
              LOOP
                nHeldQty   := colHoldQty(h);
                nHeldPrice := colHoldPrice(h);
                EXIT WHEN nNeededQty = 0;
                IF (nHeldQty > nNeededQty) THEN
                  -----
                  -- The current quantity held exceed those needed, so only a portion of the
                  -- total quantity needs to be sold as part of the Trade ...
                  -----
                  nBuyValue   := nBuyValue  + (nNeededQty * nHeldPrice);
                  nSellValue  := nSellValue + (nNeededQty * nRqstPrice);
                  nNeededQty  := 0;
                ELSE
                  -----
                  -- ... otherwise, all holdings for this security would be sold
                  -- as a result of this Trade
                  -----
                  nBuyValue   := nBuyValue  + (nHeldQty * nHeldPrice);
                  nSellValue  := nSellValue + (nHeldQty * nRqstPrice);
                  nNeededQty  := (nNeededQty - nHeldQty);
                END IF;
              END LOOP;
          ----
          -- NOTE: If the Quantity Needed for the Sale is still > 0 at this point,
          -- then the Customer would be liquidating all current holdings for this Security and
          -- then creating a new short position for the remaining balance of this transaction.
          -----
          END IF;
        ELSE
        -----
        -- ... otherwise, this is a a Buy transaction, so:
        --   2.) Short positions will be covered before opening a long position for
        --       this security.
        -----
          IF (nHeldSmyQty < 0) THEN
          -- There is an existing short position to buy
            IF (bIsLIFO = 1) THEN
              OPEN  curNewestHoldingsFirst;
              FETCH curNewestHoldingsFirst BULK COLLECT INTO colHoldQty, colHoldPrice;
              CLOSE curNewestHoldingsFirst;
            ELSE
              OPEN curOldestHoldingsFirst;
              FETCH curOldestHoldingsFirst BULK COLLECT INTO colHoldQty, colHoldPrice;
              CLOSE curOldestHoldingsFirst;
            END IF;
            -----
            -- Estimate, based on the requested price, any profit that may be realized
            -- by covering short postions currently held for this security. The customer
            -- may have multiple holdings at different prices for this security
            -- (representing multiple purchases at different times).
            -----
            FOR h IN 1 .. colHoldQty.COUNT
              LOOP
                nHeldQty   := colHoldQty(h);
                nHeldPrice := colHoldPrice(h);
                EXIT WHEN nNeededQty = 0;
                -----
                -- Is the total amount of Held plus Needed issues less than zero (0)?
                -----
                IF ((nHeldQty + nNeededQty) < 0) THEN
                  -----
                  -- If so, only a portion of this holding would be covered
                  -- (i.e. bought back) as a result of this trade ...
                  -----
                  nSellValue  := nSellValue + (nNeededQty * nHeldPrice);
                  nBuyValue   := nBuyValue + (nNeededQty * nRqstPrice);
                  nNeededQty  := 0;
                ELSE
                  -----
                  -- ... otherwise, +all+ of this holding would be covered
                  -- (i.e. bought back) as a result of this trade. Note that
                  -- the impact to any currently-held short positions for the
                  -- Security are represented as a +negative+ quantity in
                  -- the nHeldQty variable, which is reverted to a positive
                  -- number for sake of calculation of the impact on the
                  -- Holding's current value.
                  -----
                  nHeldQty    := nHeldQty * (-1);
                  nSellValue  := nSellValue + (nHeldQty * nHeldPrice);
                  nBuyValue   := nBuyValue + (nHeldQty * nRqstPrice);
                  nNeededQty  := (nNeededQty - nHeldQty);
                END IF;
              END LOOP;
          -----
          -- End of short position processing. Note that if the Quantity Needed
          -- for the Sale is still > 0 at this point,  then the Customer will have to
          -- cover all short positions (if any) for this Security and then create a
          -- new Long position for the remaining balance of this transaction
          -----
          END IF;
        -- End of Sale vs. Buy Transaction logic
        END IF;
        -----
        -- Capital Gains Processing:
        -- Estimate any capital gains tax that would be incurred as a result of this transaction
        -----
        nTaxableAmt := 0;
        IF ((nSellValue > nBuyValue) AND (nTaxStatus IN (1,2))) THEN
          -----
          -- Customers may be subject to more than one tax at different rates.
          -- Therefore, capture the sum of the tax rates that apply to the customer
          -- and estimate the overall amount of tax that would result from this order
          -----
          SELECT SUM(tx_rate)
            INTO nTaxRate
            FROM tax_rate
           WHERE tx_id IN (SELECT cx_tx_id
                             FROM customer_taxrate
                           WHERE cx_c_id = nCustAcctID);
          nTaxableAmt := (nSellValue - nBuyValue) * nTaxRate;
        END IF;
        -----
        -- Calculate administrative fees (e.g. trading charge, commision rate)
        -----
        SELECT cr_rate
          INTO nCommRate
          FROM commission_rate
         WHERE cr_c_tier = nCustTier
           AND cr_tt_id = vcTradeType
           AND cr_ex_id = nExchgID
           AND cr_from_qty <= nRqstQty
           AND cr_to_qty >= nRqstQty;
        SELECT ch_chrg
          INTO nChgRate
          FROM charge
         WHERE ch_c_tier = nCustTier
           AND ch_tt_id = vcTradeType;
        -----
        -- Compute assets on Margin Trades. Note that Margin Trades
        -- occur on a random basis, approximately 20% of the time
        -----
        nAcctAssets := 0;
        bIsMargin := ROUND(DBMS_RANDOM.VALUE(1,5),0);
        IF (bIsMargin = 1) THEN
          BEGIN
            SELECT ca_bal
              INTO nAcctBalance
              FROM customer_account
             WHERE ca_id = nCustAcctID;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              nAcctBalance := 0;
          END;
        END IF;
        -----
        -- If the Account currently has no holdings, then compute the total Account
        -- Assets as the Account Balance; otherwise, compute total Account Assets
        -- as Held Assets plus the Account Balance
        -----
        BEGIN
          SELECT SUM(hs_qty * lt_price)
            INTO nHeldAssets
            FROM
              holding_summary
             ,last_trade
           WHERE lt_s_symb = hs_s_symb
             AND hs_ca_id = nCustAcctID;
          nAcctAssets := (nHeldAssets + nAcctBalance);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            nAcctAssets := nAcctBalance;
        END;
        -----
        -- Set the status for this trade
        -----
        IF (bAtMrkt = 1) THEN
          vcTradeStatus := 'SBMT';
        ELSE
          vcTradeStatus := 'PNDG';
        END IF;
        -----
        -- Frame 4:
        -- Add new rows into appropriate trade transaction tables:
        -- 1.) Derive new value for Trade ID from table's corresponding SEQUENCE
        -- 2.) Record trade information in TRADE table
        -- 3.) If this is a Limit order, then record pending trade information
        --     into TRADE_REQUEST table for later processing as part of the
        --     Market-Feed transaction
        -- 4.) Record trade information into TRADE_HISTORY table
        -----
        SELECT TRADE_SEQ.NEXTVAL INTO nNewTradeID FROM DUAL;
        IF bIsMargin = 1 THEN
          bIsCash := 0;
        ELSE
          bIsCash := 1 ;
        END IF;
        tsNewTrade :=
          TO_TIMESTAMP((DFLT_TRADE_DATE || '.' ||ROUND(DBMS_RANDOM.VALUE(07,09),0) || ':' ||
                ROUND(DBMS_RANDOM.VALUE(10,59),0) || ':' || ROUND(DBMS_RANDOM.VALUE(10,59),0)),
                'YYYY-MM-DD.HH24:MI:SS');
        nCommAmt := (nRqstQty * nRqstPrice * nCommRate);
        nChrgAmt := (nRqstQty * nRqstPrice * nChgRate);
        INSERT INTO trade (
             t_id
            ,t_dts
            ,t_st_id
            ,t_tt_id
            ,t_is_cash
            ,t_s_symb
            ,t_qty
            ,t_bid_price
            ,t_ca_id
            ,t_exec_name
            ,t_trade_price
            ,t_chrg
            ,t_comm
            ,t_tax
            ,t_lifo)
        VALUES (
             nNewTradeID
            ,tsNewTrade
            ,vcTradeStatus
            ,vcTradeType
            ,bIsCash
            ,vcSymbol
            ,nRqstQty
            ,nRqstPrice
            ,nCustAcctID
            ,(vcCustFName || vcCustLname)
            ,nRqstPrice
            ,nChrgAmt
            ,nCommAmt
            ,0
            ,bIsLIFO);
        increment_inserts(1);
        IF (bAtMrkt <> 1) THEN
          INSERT INTO trade_request (
             tr_t_id
            ,tr_tt_id
            ,tr_s_symb
            ,tr_qty
            ,tr_bid_price
            ,tr_b_id)
          VALUES (
             nNewTradeID
            ,vcTradeType
            ,vcSymbol
            ,nRqstQty
            ,nRqstPrice
            ,nBrokerID);
          increment_inserts(1);
        END IF;
        INSERT INTO trade_history (
            th_t_id
           ,th_dts
           ,th_st_id)
        VALUES (
             nNewTradeID
            ,tsNewTrade
            ,vcTradeStatus);
        increment_inserts(1);
          -----
          -- Frame 5:
          -- 1.) Determine if a pending transaction should be rolled back
          --     at random. (Approximately 5% of all transactions are rolled
          --     back to simulate order cancellation.)
          -- 2.) Process any other RAISEd exceptions and roll back any
          --     pending transaction elements.
          -- 3.) Otherwise, COMMIT the transaction.
          -----
          sleep(min_sleep, max_sleep);
          DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
          nRollItBack := ROUND(DBMS_RANDOM.VALUE(1,20),0);
          IF (nRollItBack = 11) THEN
            ROLLBACK;
            increment_rollbacks(1);
          ELSE
            COMMIT;
            increment_commits(1);
            -----
            -- Finally, if it has a Submitted status, submit
            -- this Trade for processing and settlement. (Trades
            -- with a Pending status are handled within the
            -- MarketFeed transaction.)
            -----
            IF (vcTradeStatus = 'SBMT') THEN
               ProcessTradeResult(nNewTradeID);
            END IF;
          END IF;
          RETURN info_array;
        EXCEPTION
          WHEN unverified_purchaser THEN
            ROLLBACK;
            increment_rollbacks(1);
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
            RAISE;
          WHEN OTHERS THEN
            ROLLBACK;
            increment_rollbacks(1);
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
            RAISE;
    END MntTradeOrder;
    -----
    -- Function:    MntTradeResult
    -- Scope:       PUBLIC
    -- Purpose:     Submits any remaining Trades with a status of SBMT (Submitted)
    --              for processing, starting with the Brokerage with the highest
    --              number of submitted Trades
    -- Notes:       See TPC-E Specification Section 3.3.8
    -----
    FUNCTION MntTradeResult(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array
    IS
      nBrokerID broker.b_id%TYPE;
      nTradeID  trade.t_id%TYPE;
      CURSOR curSubmittedTrades IS
        SELECT
           t_id
          FROM
            trade
           ,customer_account
           ,broker
         WHERE b_id = nBrokerID
           AND ca_id = t_ca_id
           AND t_st_id = 'SBMT';
      TYPE typTradeID
        IS TABLE OF TRADE.t_id%TYPE
        INDEX BY PLS_INTEGER;
      colTradeID      typTradeID;
    BEGIN
      DBMS_APPLICATION_INFO.SET_MODULE('Trade Result Transaction',NULL);
      init_info_array();
      sleep(min_sleep, max_sleep);
      -- Get random Broker ID
      nBrokerID := GetSubmittedTradesBrokerID;
      -- Process all Trades related to that Broker ID
      IF (nBrokerID <> 0) THEN
        OPEN curSubmittedTrades;
        FETCH curSubmittedTrades BULK COLLECT INTO colTradeID;
        CLOSE curSubmittedTrades;
        FOR t IN 1 .. colTradeID.COUNT
          LOOP
            nTradeID    := colTradeID(t);
            ProcessTradeResult(nTradeID);
          END LOOP;
      END IF;
      sleep(min_sleep, max_sleep);
      DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
      RETURN info_array;
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
        ROLLBACK;
        increment_rollbacks(1);
        RAISE;
    END MntTradeResult;
    -----
    -- Function:    MntTradeUpdate
    -- Scope:       PUBLIC
    --              The Trade-Update Transaction series is designed to emulate the
    --              process of making minor corrections or updates to a set of trades.
    --              This is analogous to a customer or broker reviewing a set of trades,
    --              and discovering that some minor editorial corrections are required.
    --              The various sets of trades are chosen such that the work is
    --              representative of:
    --              > Reviewing general market trends
    --              > Reviewing trades for a period of time prior to the most recent account statement
    --              > Reviewing past performance of a particular security
    -- Usage Notes: TPC-E Specification 3.3.10
    --              Three different frames are presented:
    --              > Frame #1 (33%): Updates the Trade Executor's name in TRADE
    --              > Frame #2 (33%): Updates Settlement information in SETTLEMENT
    --              > Frame #3 (34%): Updates Cash Transaction information in CASH_TRANSACTION
    -----
    FUNCTION MntTradeUpdate(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array
    IS
      nFrame            NUMBER  := 0;
      nMaxTrades        NUMBER  := 0;
      nMaxUpdates       NUMBER  := 0;
      nTradesFound      NUMBER  := 0;
      nTradesUpdated    NUMBER  := 0;
      nRowsRetrieved    NUMBER  := 0;
      tsCashTime        cash_transaction.ct_dts%TYPE;
      nCashAmt          cash_transaction.ct_amt%TYPE;
      vcCashTransName   cash_transaction.ct_name%TYPE;
      nCustAcctID       customer_account.ca_id%TYPE;
      nMaxCustAcctID    customer_account.ca_id%TYPE;
      vcSymbol          security.s_symb%TYPE;
      vcSettleCashType  settlement.se_cash_type%TYPE;
      dtSettleDue       settlement.se_cash_due_date%TYPE;
      nSettleAmt        settlement.se_amt%TYPE;
      nMinTradeID       trade.t_id%TYPE;
      nMaxTradeID       trade.t_id%TYPE;
      vcTradeExecName   trade.t_exec_name%TYPE;
      nTradePrice       trade.t_trade_price%TYPE;
      nTradeBidPrice    trade.t_bid_price%TYPE;
      tsTradeBeg        trade.t_dts%TYPE;
      tsTradeEnd        trade.t_dts%TYPE;
      bIsCash           trade.t_is_cash%TYPE;
      nTradeHistTID     trade_history.th_t_id%TYPE;
      nTTIsMrkt         trade_type.tt_is_mrkt%TYPE;
      TYPE typTradeID
        IS TABLE OF TRADE.t_id%TYPE
        INDEX BY PLS_INTEGER;
      colTradeIDs     typTradeID;
      TYPE typCashTrade
        IS TABLE OF TRADE.t_is_cash%TYPE
        INDEX BY PLS_INTEGER;
      colCashTrades     typCashTrade;
      TYPE recTradeHistStatus
        IS RECORD (
          tsTradeHist       trade_history.th_dts%TYPE
         ,vcTradeHistStatus trade_history.th_st_id%TYPE
      );
      CURSOR curTradeHistStatus
        RETURN recTradeHistStatus
      IS
      SELECT
           th_dts
          ,th_st_id
        FROM trade_history
       WHERE th_t_id = nTradeHistTID
      ORDER BY th_dts
      FETCH FIRST 3 ROWS ONLY;
      TradeHistStatusInfo   recTradeHistStatus;
      CURSOR curTradeIDs IS
        SELECT
             t_id
            ,t_is_cash
          FROM trade
         WHERE t_id BETWEEN nMinTradeID AND nMaxTradeID
         ORDER BY t_id ASC
         FETCH FIRST 20 ROWS ONLY;
      CURSOR curTradesByCustomer IS
        SELECT t_id, t_is_cash
          FROM (SELECT
                     t_id
                    ,t_is_cash
                  FROM trade
                 WHERE t_ca_id = nCustAcctID
                   AND t_dts >= tsTradeBeg
                   AND t_dts <= tsTradeEnd
                 ORDER BY t_dts ASC)
         WHERE rownum <= nMaxTrades;
      CURSOR curTradeSecurities IS
        SELECT
             t_ca_id
            ,t_exec_name
            ,t_is_cash
            ,t_trade_price
            ,t_qty
            ,s_name
            ,t_dts
            ,t_id
            ,t_tt_id
            ,tt_name
          FROM
             trade
            ,trade_type
            ,security
         WHERE t_s_symb = vcSymbol
           AND t_dts >= tsTradeBeg
           AND t_dts <= tsTradeEnd
           AND tt_id = t_tt_id
           AND s_symb = t_s_symb
           AND t_ca_id <= nMaxCustAcctID
        ORDER BY t_dts ASC
        FETCH FIRST 20 ROWS ONLY;
    BEGIN
      DBMS_APPLICATION_INFO.SET_MODULE('Trade Update Transaction',NULL);
      init_info_array();
      sleep(min_sleep, max_sleep);
      -----
      -- Frame Control:
      -- Select a random frame (1-3)
      -- Set up number of trades to retrieve (in range of 10 - 20)
      -- Set up number of trades to update (always less than number of
      -- Trades retrieved, but always at least two (2))
      -----
      nFrame      := ROUND(DBMS_RANDOM.VALUE(1,3),0);
      nMaxTrades  := ROUND(DBMS_RANDOM.VALUE(10,20),0);
      nMaxUpdates := nMaxTrades - ROUND(DBMS_RANDOM.VALUE(1,8),0);
      CASE nFrame
        WHEN 1 THEN
            -----
            -- Frame 1:
            -- 1.) Gather a random collection of Trades directly from TRADE
            -- 2.) Modify the Trade Executor's name to simulate user updates
            -- 3.) Query the Trade's corresponding information for:
            --     a.) Trade Pricing
            --     b.) Settlement
            --     c.) Cash Transaction
            --     d.) Trade History
            -----
            BEGIN
              nTradesFound    := 0;
              nTradesUpdated  := 0;
              nMinTradeID     := ROUND(DBMS_RANDOM.VALUE(MIN_TRADE_ID,MAX_TRADE_ID),0);
              nMaxTradeID     := nMinTradeID + 100;
              OPEN  curTradeIDs;
              FETCH curTradeIDs BULK COLLECT INTO colTradeIDs, colCashTrades;
              CLOSE curTradeIDs;
              FOR i IN 1 .. colTradeIDs.COUNT
                LOOP
                  EXIT WHEN (nTradesUpdated >= nMaxUpdates);
                    SELECT t_exec_name
                      INTO vcTradeExecName
                      FROM trade
                     WHERE t_id = colTradeIDs(i);
                    increment_selects(1);
                    nTradesFound := nTradesFound + 1;
                    -----
                    -- Change the Trade Executor's name slightly and apply it to
                    -- the Trade to simulate a "user touch"
                    -----
                    IF (vcTradeExecName LIKE '%X%') THEN
                      vcTradeExecName := REPLACE (vcTradeExecName, 'X', ' ');
                    ELSE
                      vcTradeExecName := REPLACE (vcTradeExecName, ' ', 'X');
                    END IF;
                    UPDATE trade
                       SET t_exec_name = vcTradeExecName
                     WHERE t_id = colTradeIDs(i);
                    increment_updates(1);
                    nTradesUpdated := nTradesUpdated + 1;
                  -----
                  -- Retrieve Trade Pricing attributes
                  -----
                  SELECT
                       t_bid_price
                      ,t_exec_name
                      ,t_is_cash
                      ,tt_is_mrkt
                      ,t_trade_price
                    INTO
                       nTradeBidPrice
                      ,vcTradeExecName
                      ,bIsCash
                      ,nTTIsMrkt
                      ,nTradePrice
                    FROM
                       trade
                      ,trade_type
                   WHERE t_tt_id = tt_id
                     AND t_id = colTradeIDs(i);
                  increment_selects(1);
                  -----
                  -- Retrieve Settlement information for each Trade
                  -----
                  BEGIN
                    SELECT
                         se_amt
                        ,se_cash_due_date
                        ,se_cash_type
                      INTO
                         nSettleAmt
                        ,dtSettleDue
                        ,vcSettleCashType
                      FROM settlement
                    WHERE se_t_id = colTradeIDs(i);
                  increment_selects(1);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                       BEGIN
                        nSettleAmt := 0;
                        dtSettleDue := TO_DATE(DFLT_TRADE_DATE, 'yyyy-mm-dd');
                        vcSettleCashType := 'Cash Account';
                       END;
                  END;
                  -----
                  -- If this is a cash transaction, get corresponding information
                  -----
                  IF (bIsCash = 1) THEN
                    BEGIN
                      SELECT
                           ct_amt
                          ,ct_dts
                          ,ct_name
                        INTO
                           nCashAmt
                          ,tsCashTime
                          ,vcCashTransName
                        FROM cash_transaction
                       WHERE ct_t_id = colTradeIDs(i);
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        BEGIN
                          nCashAmt := 0;
                          tsCashTime :=
                            TO_TIMESTAMP((DFLT_TRADE_DATE || '.' ||ROUND(DBMS_RANDOM.VALUE(10,12),0) || ':' ||
                                          ROUND(DBMS_RANDOM.VALUE(10,59),0) || ':' || ROUND(DBMS_RANDOM.VALUE(10,59),0)),
                                          'YYYY-MM-DD.HH24:MI:SS');
                          vcCashTransName := 'Cash Transaction';
                        END;
                    END;
                    increment_selects(1);
                  END IF;
                  -----
                  -- Retrieve Trade History information for the selected Trade, limiting
                  -- retrieval to a maximum of three (3) rows
                  -----
                  nTradeHistTID := colTradeIDs(i);
                  OPEN curTradeHistStatus;
                  LOOP
                    FETCH curTradeHistStatus INTO TradeHistStatusInfo;
                    EXIT WHEN curTradeHistStatus%NOTFOUND;
                    nRowsRetrieved := nRowsRetrieved + 1;
                  END LOOP;
                  CLOSE curTradeHistStatus;
                  increment_selects(1);
                  increment_rows_selected(nRowsRetrieved);
                END LOOP;
            -- End of Frame 1
            END;
          WHEN 2 THEN
            -----
            -- Frame 2:
            -- 1.) Gather a random collection of Trades from TRADE
            -- 2.) Modify the Trade's Settlement information to simulate user update
            -- 3.) Query the Trade's corresponding information for:
            --     a.) Settlement
            --     b.) Cash Transaction
            --     c.) Trade History
            -----
            BEGIN
              -----
              -- Retrieve Trade information, for between 0 and MAX_TRADES rows
              -- for a random Customer Account ID and a limited random range
              --- of Trade dates
              -----
              nCustAcctID := GetRandomCustomerAccountIdentifier;
              tsTradeEnd  := TO_DATE('2005-12-31', 'yyyy-mm-dd') + ROUND(DBMS_RANDOM.VALUE(1,365),0);
              tsTradeBeg  := tsTradeEnd - ROUND(DBMS_RANDOM.VALUE(180,540),0);
              OPEN  curTradesByCustomer;
              FETCH curTradesByCustomer BULK COLLECT INTO colTradeIDs, colCashTrades;
              CLOSE curTradesByCustomer;
              -----
              -- Get extra information for each Trade
              -----
              FOR i IN 1 .. colTradeIDs.COUNT
                LOOP
                  EXIT WHEN (nTradesUpdated >= nMaxUpdates);
                  -----
                  -- Modify the Settlement Cash Type information for this
                  -- Trade to simulate a "user touch"
                  -----
                  BEGIN
                    SELECT se_cash_type
                      INTO vcSettleCashType
                      FROM settlement
                     WHERE se_t_id = colTradeIDs(i);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vcSettleCashType := 'Cash Account';
                  END;
                  IF (colCashTrades(i) = 1) THEN
                    IF (vcSettleCashType = 'Cash Account') THEN
                      vcSettleCashType := 'Cash';
                    ELSE
                      vcSettleCashType := 'Cash Account';
                    END IF;
                  ELSE
                    IF (vcSettleCashType = 'Margin Account') THEN
                      vcSettleCashType := 'Margin';
                    ELSE
                      vcSettleCashType := 'Margin Account';
                    END IF;
                  END IF;
                  UPDATE settlement
                     SET se_cash_type = vcSettleCashType
                   WHERE se_t_id = colTradeIDs(i);
                  increment_updates(1);
                  nTradesUpdated := nTradesUpdated + 1;
                  -----
                  -- Get settlement information for selected Trade
                  -----
                  BEGIN
                    SELECT
                         se_amt
                        ,se_cash_due_date
                        ,se_cash_type
                      INTO
                         nSettleAmt
                        ,dtSettleDue
                        ,vcSettleCashType
                      FROM settlement
                    WHERE se_t_id = colTradeIDs(i);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                       BEGIN
                        nSettleAmt := 0;
                        dtSettleDue := TO_DATE(DFLT_TRADE_DATE, 'yyyy-mm-dd');
                        vcSettleCashType := 'Cash Account';
                       END;
                  END;
                  -----
                  -- If this is a Cash transaction, get corresponding information
                  -----
                  IF (colCashTrades(i) = 1) THEN
                    BEGIN
                      SELECT
                           ct_amt
                          ,ct_dts
                          ,ct_name
                        INTO
                           nCashAmt
                          ,tsCashTime
                          ,vcCashTransName
                        FROM cash_transaction
                       WHERE ct_t_id = colTradeIDs(i);
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        BEGIN
                          nCashAmt := 0;
                          tsCashTime :=
                            TO_TIMESTAMP((DFLT_TRADE_DATE || '.' ||ROUND(DBMS_RANDOM.VALUE(10,12),0) || ':' ||
                                          ROUND(DBMS_RANDOM.VALUE(10,59),0) || ':' || ROUND(DBMS_RANDOM.VALUE(10,59),0)),
                                          'YYYY-MM-DD.HH24:MI:SS');
                          vcCashTransName := 'Cash Transaction';
                        END;
                    END;
                    increment_selects(1);
                  END IF;
                  -----
                  -- Retrieve Trade History information for the selected Trade, limiting
                  -- retrieval to a maximum of three (3) rows
                  -----
                  nTradeHistTID := colTradeIDs(i);
                  OPEN curTradeHistStatus;
                  LOOP
                    FETCH curTradeHistStatus INTO TradeHistStatusInfo;
                    EXIT WHEN curTradeHistStatus%NOTFOUND;
                    nRowsRetrieved := nRowsRetrieved + 1;
                  END LOOP;
                  CLOSE curTradeHistStatus;
                  increment_selects(1);
                  increment_rows_selected(nRowsRetrieved);
                END LOOP;
            -- End of Frame 2
            END;
          ELSE
            -----
            -- Frame 3:
            -- 1.) Gather a random collection of Trades from TRADE, TRADE_TYPE,
            --     and SECURITY
            -- 2.) Modify the Trade's Cash Transaction information to simulate user update
            -- 3.) Query the Trade's corresponding information for:
            --    ### FINISH FOR ACTUAL SPECS!! ###
            --     a.) Settlement
            --     b.) ...
            -----
            BEGIN
              OPEN curTradeSecurities;
              FOR i IN 1 .. colTradeIDs.COUNT
                LOOP
                  EXIT WHEN (nTradesUpdated >= nMaxUpdates);
                  SELECT
                       se_amt
                      ,se_cash_due_date
                      ,se_cash_type
                    INTO
                       nSettleAmt
                      ,dtSettleDue
                      ,vcSettleCashType
                    FROM settlement
                   WHERE se_t_id = colTradeIDs(i);
                  increment_selects(1);
                  increment_rows_selected(1);
                  IF (colCashTrades(i) = 1) THEN
                    -----
                    -- If there is a corresponding Cash Transaction for this Trade, change
                    -- its transaction description slightly to simulate a "user touch"
                    -----
                    IF (nTradesUpdated < nMaxUpdates) THEN
                      SELECT ct_name
                        INTO vcCashTransName
                        FROM cash_transaction
                       WHERE ct_t_id = colTradeIDs(i);
                      IF (vcCashTransName LIKE '%shares of%') THEN
                        vcCashTransName := REPLACE (vcCashTransName, 'shares of', 'Shares Of');
                      ELSE
                        vcCashTransName := REPLACE (vcCashTransName, 'Shares of', 'shares Of');
                      END IF;
                      UPDATE cash_transaction
                         SET ct_name = vcCashTransName
                       WHERE ct_t_id = colTradeIDs(i);
                      increment_updates(1);
                      nTradesUpdated := nTradesUpdated + 1;
                    END IF;
                    -----
                    -- Confirm the results of the updated Cash Transaction Name
                    -- Note: This update hasn't been committed yet!
                    -----
                    BEGIN
                    SELECT
                         ct_amt
                        ,ct_dts
                        ,ct_name
                      INTO
                         nCashAmt
                        ,tsCashTime
                        ,vcCashTransName
                      FROM cash_transaction
                     WHERE ct_t_id = colTradeIDs(i);
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        BEGIN
                          nCashAmt := 0;
                          tsCashTime :=
                            TO_TIMESTAMP((DFLT_TRADE_DATE || '.' ||ROUND(DBMS_RANDOM.VALUE(10,12),0) || ':' ||
                                          ROUND(DBMS_RANDOM.VALUE(10,59),0) || ':' || ROUND(DBMS_RANDOM.VALUE(10,59),0)),
                                          'YYYY-MM-DD.HH24:MI:SS');
                          vcCashTransName := 'Cash Transaction';
                        END;
                     END;
                    increment_selects(1);
                  END IF;
                    -----
                    -- Retrieve Trade History information for the selected Trade, limiting
                    -- retrieval to a maximum of three (3) rows
                    -----
                    nTradeHistTID := colTradeIDs(i);
                    OPEN curTradeHistStatus;
                    LOOP
                      FETCH curTradeHistStatus INTO TradeHistStatusInfo;
                      EXIT WHEN curTradeHistStatus%NOTFOUND;
                      nRowsRetrieved := nRowsRetrieved + 1;
                    END LOOP;
                    CLOSE curTradeHistStatus;
                    increment_selects(1);
                    increment_rows_selected(nRowsRetrieved);
                -- End of Trades Processing
                END LOOP;
            -- End of Frame 3
            END;
          -- End of ALL Frames
          COMMIT;
          increment_commits(1);
        END CASE;
        sleep(min_sleep, max_sleep);
        DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
        RETURN info_array;
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
            ROLLBACK;
            increment_rollbacks(1);
            RAISE;
    END MntTradeUpdate;
    -----
    -- Function:    MntDataMaintenance
    -- Scope:       PUBLIC
    -- Purpose:     Performs updates on selected dimension tables on a periodic
    --              basis, to simulate random and minor updates which have no
    --              impact on +any+ trade processing data.
    -- Usage Notes: TPC-E Specification 3.3.11
    --              At this time, this set of updates is not implemented as part
    --              of this module to give precedence instead to Trade processing
    --              functions and procedures instead.
    -----
    FUNCTION MntDataMaintenance(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array
    IS
    BEGIN
        DBMS_APPLICATION_INFO.SET_MODULE('Data Maintenance Processing',NULL);
        init_info_array();
        sleep(min_sleep, max_sleep);
        NULL;
        increment_updates(1);
        sleep(min_sleep, max_sleep);
        DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
        RETURN info_array;
        EXCEPTION
          WHEN OTHERS THEN
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
            RAISE;
    END MntDataMaintenance;
    -----
    -- Function:    MntTradeCleanup
    -- Scope:       PUBLIC
    -- Purpose:     Cleans up all pending unprocessed Trade Requests and any
    --              submitted but not yet processed Trades
    -- Usage Notes: This should be run immediately prior to initiating +any+
    --              TPC-E test run that includes maintenance processing as
    --              part of its planned workload simulation
    -----
    FUNCTION MntTradeCleanup(
        min_sleep INTEGER
       ,max_sleep INTEGER
    )
    RETURN integer_return_array
    IS
        nPendingTradeID     trade_request.tr_t_id%TYPE;
        nSubmittedTradeID   trade.t_id%TYPE;
        tsTradeCleanup      trade.t_dts%TYPE;
        CONS_ST_SUBMITTED   trade.t_st_id%TYPE := 'SBMT';
        CONS_ST_CANCELLED   trade_history.th_st_id%TYPE := 'CNCL';
        CURSOR curTradesPending
          IS
          SELECT tr_t_id
            FROM trade_request
           ORDER BY tr_t_id;
        CURSOR curTradesSubmitted
          IS
          SELECT t_id
            FROM trade
           WHERE t_id >= MIN_TRADE_ID
             AND t_st_id = CONS_ST_SUBMITTED;
    BEGIN
        DBMS_APPLICATION_INFO.SET_MODULE('Trade Cleanup Processing',null);
        init_info_array();
        sleep(min_sleep, max_sleep);
        -- Set timestamp to the default cleanup processing date
        tsTradeCleanup :=
          TO_TIMESTAMP((DFLT_CLEANUP_DATE || '.' ||ROUND(DBMS_RANDOM.VALUE(01,23),0) || ':' ||
                ROUND(DBMS_RANDOM.VALUE(10,59),0) || ':' || ROUND(DBMS_RANDOM.VALUE(10,59),0)),
                'YYYY-MM-DD.HH24:MI:SS');
        OPEN curTradesPending;
        LOOP
          FETCH curTradesPending INTO nPendingTradeID;
          EXIT WHEN curTradesPending%NOTFOUND;
          -----
          -- For any pending unprocessed Trade Requests:
          -- 1.) Insert a submitted followed by canceled record into TRADE_HISTORY
          -- 2.) Mark the trade as canceled in the TRADE table
          -- 3.) Delete the pending trade
          -----
          INSERT INTO trade_history (
              th_t_id
             ,th_dts
             ,th_st_id
          )
          VALUES (
              nPendingTradeID
             ,tsTradeCleanup
             ,CONS_ST_SUBMITTED);
          increment_inserts(1);
          UPDATE trade
             SET t_st_id = CONS_ST_CANCELLED
                ,t_dts = tsTradeCleanup
           WHERE t_id = nPendingTradeID;
          increment_updates(1);
          INSERT INTO trade_history (
              th_t_id
             ,th_dts
             ,th_st_id
          )
          VALUES (
              nPendingTradeID
             ,tsTradeCleanup
             ,CONS_ST_CANCELLED);
          increment_inserts(1);
        END LOOP;
        CLOSE curTradesPending;
        -----
        -- Next, remove all pending trades
        -----
        DELETE FROM trade_request;
        increment_deletes(1);
        -----
        -- For any remaining Trades still in a Submitted (SBMT) status:
        -- 1. Change their status to CANCELED
        -- 2. Add a CANCELED record into TRADE_HISTORY
        -----
        OPEN  curTradesSubmitted;
        LOOP
          FETCH curTradesSubmitted INTO nSubmittedTradeID;
          EXIT WHEN curTradesSubmitted%NOTFOUND;
          -- Mark the trade as canceled, and record the time
          UPDATE trade
             SET t_st_id = CONS_ST_CANCELLED
                ,t_dts = tsTradeCleanup
           WHERE t_id = nSubmittedTradeID;
          increment_updates(1);
          INSERT INTO trade_history (
              th_t_id
             ,th_dts
             ,th_st_id)
          VALUES (
              nSubmittedTradeID
             ,tsTradeCleanup
             ,CONS_ST_CANCELLED);
          increment_inserts(1);
        END LOOP;
        CLOSE curTradesSubmitted;
        -----
        -- Finally, commit all this work
        -----
        COMMIT;
        increment_commits(1);
        sleep(min_sleep, max_sleep);
        DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
        RETURN info_array;
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            increment_rollbacks(1);
            DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);
            RAISE;
    END MntTradeCleanup;
BEGIN
        -----
        -- Initialization processing:
        --  1.) Gather minimum and maximum values for dimensions to control
        --      generation of randomized values
        --  2.) Populate VARRAYs used to limit specific queries and DML
        -----
        InitializeAttributeArrays();
END pkg_tpce_transactions;
