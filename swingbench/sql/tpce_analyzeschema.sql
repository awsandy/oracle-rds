### STD: Add all TPCE tables

ALTER SESSION SET PLSQL_CCFLAGS = 'running_in_cloud:&running_in_cloud';

BEGIN
    DECLARE
        jobs_count number := 0;
    BEGIN
        $if not $$running_in_cloud $then
            select value into jobs_count from v$parameter
            jobs_count where name='job_queue_processes';
            $IF DBMS_DB_VERSION.VER_LE_10_2
            $THEN
            -- Use the default stats collection approach
                DBMS_STATS.GATHER_SCHEMA_STATS(
                    ownname => '&username'
                    ,estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE
                    ,block_sample => TRUE
                    ,method_opt => 'FOR ALL COLUMNS SIZE SKEWONLY'
                    ,degree => &parallelism
                    ,granularity => 'ALL'
                    ,cascade => TRUE);
            $ELSIF DBMS_DB_VERSION.VER_LE_11_2
            $THEN
                 -- Oracle 11g release 2. Emable concurrent stats collection
                DBMS_STATS.SET_TABLE_PREFS('&username','ACCOUNT_PERMISSION','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','ADDRESS','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','BROKER','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','CASH_TRANSACTION','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','CHARGE','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','COMMISSION_RATE','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','COMPANY','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','COMPANY_COMPETITOR','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','CUSTOMER','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','CUSTOMER_ACCOUNT','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','CUSTOMER_TAXRATE','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','DAILY_MARKET','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','EXCHANGE','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','FINANCIAL','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','HOLDING','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','HOLDING_HISTORY','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','HOLDING_SUMMARY','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','INDUSTRY','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','LAST_TRADE','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','NEWS_ITEM','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','NEWS_XREF','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','SECTOR','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','SECURITY','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','SETTLEMENT','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','STATUS_TYPE','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','TAX_RATE','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','TRADE','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','TRADE_HISTORY','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','TRADE_REQUEST','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','TRADE_TYPE','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','WATCH_ITEM','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','WATCH_LIST','INCREMENTAL','TRUE');
                DBMS_STATS.SET_TABLE_PREFS('&username','ZIP_CODE','INCREMENTAL','TRUE');
                DBMS_STATS.GATHER_SCHEMA_STATS('&username');
            $ELSE
             -- Oracle 12c. Concurrent Stats collection work slightly different in this release
                 EXECUTE IMMEDIATE q'[ALTER SYSTEM SET RESOURCE_MANAGER_PLAN = 'DEFAULT_PLAN']';
                 if jobs_count < &parallelism then
                     EXECUTE IMMEDIATE q'[ALTER SYSTEM SET JOB_QUEUE_PROCESSES = &parallelism ]';
                 end if;
                 DBMS_STATS.SET_TABLE_PREFS('&username','ACCOUNT_PERMISSION','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','ADDRESS','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','BROKER','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','CASH_TRANSACTION','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','CHARGE','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','COMMISSION_RATE','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','COMPANY','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','COMPANY_COMPETITOR','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','CUSTOMER','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','CUSTOMER_ACCOUNT','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','CUSTOMER_TAXRATE','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','DAILY_MARKET','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','EXCHANGE','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','FINANCIAL','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','HOLDING','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','HOLDING_HISTORY','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','HOLDING_SUMMARY','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','INDUSTRY','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','LAST_TRADE','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','NEWS_ITEM','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','NEWS_XREF','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','SECTOR','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','SECURITY','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','SETTLEMENT','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','STATUS_TYPE','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','TAX_RATE','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','TRADE','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','TRADE_HISTORY','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','TRADE_REQUEST','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','TRADE_TYPE','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','WATCH_ITEM','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','WATCH_LIST','INCREMENTAL','TRUE');
                 DBMS_STATS.SET_TABLE_PREFS('&username','ZIP_CODE','INCREMENTAL','TRUE');
                 DBMS_STATS.GATHER_SCHEMA_STATS('&username');
            $END
        $else
            DBMS_STATS.GATHER_SCHEMA_STATS(ownname => '&username',
                                           estimate_percent => dbms_stats.auto_sample_size,
                                           block_sample => true,
                                           method_opt =>'FOR ALL COLUMNS SIZE SKEWONLY',
                                           degree => &parallelism,
                                           granularity => 'ALL',
                                           cascade => true);
        $end
    end;
end;
/

--End
                