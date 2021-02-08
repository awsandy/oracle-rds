create user DMS identified by "linuxpassword0182";
GRANT CREATE SESSION TO DMS;
GRANT SELECT ANY TRANSACTION TO DMS;
GRANT SELECT ON V_$ARCHIVED_LOG TO DMS;
GRANT SELECT ON V_$LOG TO DMS;
GRANT SELECT ON V_$LOGFILE TO DMS;
GRANT SELECT ON V_$LOGMNR_LOGS TO DMS;
GRANT SELECT ON V_$LOGMNR_CONTENTS TO DMS;
GRANT SELECT ON V_$DATABASE TO DMS;
GRANT SELECT ON V_$THREAD TO DMS;
GRANT SELECT ON V_$PARAMETER TO DMS;
GRANT SELECT ON V_$NLS_PARAMETERS TO DMS;
GRANT SELECT ON V_$TIMEZONE_NAMES TO DMS;
GRANT SELECT ON V_$TRANSACTION TO DMS;
GRANT SELECT ON ALL_INDEXES TO DMS;
GRANT SELECT ON ALL_OBJECTS TO DMS;
GRANT SELECT ON ALL_TABLES TO DMS;
GRANT SELECT ON ALL_USERS TO DMS;
GRANT SELECT ON ALL_CATALOG TO DMS;
GRANT SELECT ON ALL_CONSTRAINTS TO DMS;
GRANT SELECT ON ALL_CONS_COLUMNS TO DMS;
GRANT SELECT ON ALL_TAB_COLS TO DMS;
GRANT SELECT ON ALL_IND_COLUMNS TO DMS;
GRANT SELECT ON ALL_ENCRYPTED_COLUMNS TO DMS;
GRANT SELECT ON ALL_LOG_GROUPS TO DMS;
GRANT SELECT ON ALL_TAB_PARTITIONS TO DMS;
GRANT SELECT ON SYS.DBA_REGISTRY TO DMS;
GRANT SELECT ON SYS.OBJ$ TO DMS;
GRANT SELECT ON DBA_TABLESPACES TO DMS;

/*#GRANT SELECT ON DBA_OBJECTS TO DMS; -– Required if the Oracle version is earlier than 11.2.0.3.
#GRANT SELECT ON SYS.ENC$ TO DMS; -– Required if transparent data encryption (TDE) is enabled. For more information on using Oracle TDE with AWS DMS, see .*/

ALTER database ARCHIVELOG;
/* supplimental logging */
SELECT supplemental_log_data_min FROM v$database;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;

EXECUTE on DBMS_LOGMNR
SELECT on V_$LOGMNR_LOGS
SELECT on V_$LOGMNR_CONTENTS
GRANT LOGMINING   /*-– Required only if the Oracle version is 12c or later. */
/*
SELECT on v_$transportable_platform -– Grant this privilege if the redo logs are stored in Oracle Automatic Storage Management (ASM) and AWS DMS accesses them from ASM.
CREATE ANY DIRECTORY -– Grant this privilege to allow AWS DMS to use Oracle BFILE read file access in certain cases. This access is required when the replication instance doesn't have file-level access to the redo logs and the redo logs are on non-ASM storage.
EXECUTE on DBMS_FILE_TRANSFER package -– Grant this privilege to copy the redo log files to a temporary folder using the CopyToTempFolder method.
EXECUTE on DBMS_FILE_GROUP
*/

