/* ora1.at.sa-demos.net  */
/*create user soe identified by "linuxpassword0182";*/
GRANT CREATE SESSION TO soe;
/*GRANT resource TO soe; */
/*GRANT connect  TO soe; */
GRANT CREATE SESSION TO soe;
GRANT SELECT ANY TRANSACTION TO soe;
GRANT SELECT ON V_$ARCHIVED_LOG TO soe;
GRANT SELECT ON V_$LOG TO soe;
GRANT SELECT ON V_$LOGFILE TO soe;
GRANT SELECT ON V_$LOGMNR_LOGS TO soe;
GRANT SELECT ON V_$LOGMNR_CONTENTS TO soe;
GRANT SELECT ON V_$DATABASE TO soe;
GRANT SELECT ON V_$THREAD TO soe;
GRANT SELECT ON V_$PARAMETER TO soe;
GRANT SELECT ON V_$NLS_PARAMETERS TO soe;
GRANT SELECT ON V_$TIMEZONE_NAMES TO soe;
GRANT SELECT ON V_$TRANSACTION TO soe;
GRANT SELECT ON ALL_INDEXES TO soe;
GRANT SELECT ON ALL_OBJECTS TO soe;
GRANT SELECT ON ALL_TABLES TO soe;
GRANT SELECT ON ALL_USERS TO soe;
GRANT SELECT ON ALL_CATALOG TO soe;
GRANT SELECT ON ALL_CONSTRAINTS TO soe;
GRANT SELECT ON ALL_CONS_COLUMNS TO soe;
GRANT SELECT ON ALL_TAB_COLS TO soe;
GRANT SELECT ON ALL_IND_COLUMNS TO soe;
GRANT SELECT ON ALL_ENCRYPTED_COLUMNS TO soe;
GRANT SELECT ON ALL_LOG_GROUPS TO soe;
GRANT SELECT ON ALL_TAB_PARTITIONS TO soe;
GRANT SELECT ON SYS.DBA_REGISTRY TO soe;
GRANT SELECT ON SYS.OBJ$ TO soe;
GRANT SELECT ON DBA_TABLESPACES TO soe;

/*#GRANT SELECT ON DBA_OBJECTS TO soe; -– Required if the Oracle version is earlier than 11.2.0.3.
#GRANT SELECT ON SYS.ENC$ TO soe; -– Required if transparent data encryption (TDE) is enabled. For more information on using Oracle TDE with AWS DMS, see .*/
archive log list;
alter databse close;
ALTER database ARCHIVELOG;
shut immediate;
startup;
select open_mode from v$database;
/* supplimental logging */
SELECT supplemental_log_data_min FROM v$database;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;

Grant EXECUTE on DBMS_LOGMNR to soe;
grant SELECT on V_$LOGMNR_LOGS to soe;
grant SELECT on V_$LOGMNR_CONTENTS to soe;
/*-– Required only if the Oracle version is 12c or later. */
GRANT LOGMINING to soe;    
/*
SELECT on v_$transportable_platform -– Grant this privilege if the redo logs are stored in Oracle Automatic Storage Management (ASM) and AWS DMS accesses them from ASM.
CREATE ANY DIRECTORY -– Grant this privilege to allow AWS DMS to use Oracle BFILE read file access in certain cases. This access is required when the replication instance doesn't have file-level access to the redo logs and the redo logs are on non-ASM storage.
EXECUTE on DBMS_FILE_TRANSFER package -– Grant this privilege to copy the redo log files to a temporary folder using the CopyToTempFolder method.
EXECUTE on DBMS_FILE_GROUP
*/

