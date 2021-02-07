export ORACLE_SID=orcl
sqlplus / as sysdba
startup mount
alter database open



ALTER PLUGGABLE DATABASE plorcl OPEN READ WRITE;

SELECT * FROM dba_temp_free_space;
CREATE TEMPORARY TABLESPACE temp2 TEMPFILE 'temp2.dbf' SIZE 2000m;
ALTER DATABASE DEFAULT TEMPORARY TABLESPACE temp2;