export ORACLE_SID=orcl
sqlplus / as sysdba
startup mount
alter database open



ALTER PLUGGABLE DATABASE plorcl OPEN READ WRITE;

SELECT * FROM dba_temp_free_space;
CREATE TEMPORARY TABLESPACE temp2 TEMPFILE 'temp2.dbf' SIZE 2000m;
ALTER DATABASE DEFAULT TEMPORARY TABLESPACE temp2;


echo "startup mount;" | sqlplus / as sysdba >> ~/dbinstall.txt


./oewizard  -dbap manager -u soe -p soe -cl -cs //localhost/plorcl -ts SOE -scale 1 -df /u02/oradata/soe.dbf -create
# 1 thread 2m 19 - 2 threads 3m 52 - 4 threads 2m 42
# 4 threads -allindexes 2m48
