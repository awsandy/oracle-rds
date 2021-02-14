-- ON SOURCE DB (NON RDS) (as SYSDBA)
-- DMS onnection attitrubtes addSupplementalLogging=Y;readTableSpaceName=true;archivedLogDestId=1;exposeViews=true
-- other attributes
-- https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.Oracle.html
CREATE user DMS identified by <PASSWORD> default tablespace DATA temporary tablespace DATA_TEMP;
-- Change the above to whatever tablespaces you have configured
Grant CREATE session to DMS;
Grant ALTER ANY TABLE to DMS; 
Grant EXECUTE on dbms_crypto to DMS;
Grant SELECT on ALL_VIEWS to DMS;
Grant SELECT ANY TABLE to DMS;
Grant SELECT ANY TRANSACTION to DMS;
Grant SELECT on V_$ARCHIVED_LOG to DMS;
Grant SELECT on V_$LOG to DMS;
Grant SELECT on V_$LOGFILE to DMS;
Grant SELECT on V_$DATABASE to DMS;
Grant SELECT on V_$THREAD to DMS;
Grant SELECT on V_$PARAMETER to DMS;
Grant SELECT on V_$NLS_PARAMETERS to DMS;
Grant SELECT on V_$TIMEZONE_NAMES to DMS;
Grant SELECT on V_$TRANSACTION to DMS;
Grant SELECT on ALL_INDEXES to DMS;
Grant SELECT on ALL_OBJECTS to DMS;
Grant SELECT on DBA_OBJECTS to DMS; 
Grant SELECT on ALL_TABLES to DMS;
Grant SELECT on ALL_USERS to DMS;
Grant SELECT on ALL_CATALOG to DMS;
Grant SELECT on ALL_CONSTRAINTS to DMS;
Grant SELECT on ALL_CONS_COLUMNS to DMS;
Grant SELECT on ALL_TAB_COLS to DMS;
Grant SELECT on ALL_IND_COLUMNS to DMS;
Grant SELECT on ALL_LOG_GROUPS to DMS;
Grant SELECT on SYS.DBA_REGISTRY to DMS;
Grant SELECT on SYS.OBJ$ to DMS;
Grant SELECT on DBA_TABLESPACES to DMS;
Grant SELECT on ALL_TAB_PARTITIONS to DMS;
Grant SELECT on ALL_ENCRYPTED_COLUMNS to DMS;
Grant SELECT on V_$LOGMNR_LOGS to DMS;
Grant SELECT on V_$LOGMNR_CONTENTS to DMS;
Grant LOGMINING TO DMS;
Grant EXECUTE ON dbms_logmnr TO DMS;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;

-- Ensure archive logging is enabled and if its not, here is how to enable it (CAUTION. This turns off the database if "shutdown immediate" wasn't clear enough.) 
shutdown immediate;
startup mount;
alter database archivelog;
alter database open;
select dest_id,dest_name, status, destination from v$archive_dest;  

-- find tables which have a primary key.
select at.TABLE_NAME
from all_tables at
where not exists (select 1
from all_constraints ac
where ac.owner = at.owner
and ac.table_name = at.table_name
and ac.constraint_type = 'P')
and at.owner = '<SCHEMA>';
-- This will list the tables with a primary key, you can then construct your supplemental logging statement based on the column which has the primay key.
-- ALTER TABLE <table_name> ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS

SELECT DISTINCT (a.table_name)
FROM ALL_CONS_COLUMNS A
JOIN ALL_CONSTRAINTS C
ON A.CONSTRAINT_NAME = C.CONSTRAINT_NAME
WHERE
C.CONSTRAINT_TYPE not in('P')
and a.owner ='<SCHEMA>';

-- This will list all the tables without a primary key, these tables need supplemental logging on all columns. 
--
-- If you run the following and then execute all statements generated, ensure that supplemental logging is enabled on ALL TABLES and COLUMNS.
-- Which will cause a greater performance hit. YMMV.
-- select 'ALTER TABLE '||table_name||' ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;' from all_tables where owner = '<SCHEMA>'