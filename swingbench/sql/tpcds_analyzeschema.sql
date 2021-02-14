BEGIN
    DBMS_STATS.set_global_prefs (
            pname   => 'CONCURRENT',
            pvalue  => 'AUTOMATIC');
END;
/

begin
    dbms_stats.gather_schema_stats(ownname => '&username',
                                            estimate_percent => dbms_stats.auto_sample_size,
                                            block_sample => true,
                                            method_opt =>'FOR ALL COLUMNS SIZE SKEWONLY',
                                            degree => &parallelism,
                                            granularity => 'ALL',
                                            cascade => true);
end;
/

--End
