BEGIN
    DBMS_STATS.set_global_prefs (
            pname   => 'CONCURRENT',
            pvalue  => 'AUTOMATIC');
END;
/

BEGIN
    dbms_stats.gather_schema_stats(
         ownname=>SYS_CONTEXT('USERENV','CURRENT_SCHEMA')
        ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE
        ,block_sample=>true
        ,method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY'
        ,degree=>&parallelism
        ,granularity=>'ALL'
        ,cascade=>true);
END;
/

