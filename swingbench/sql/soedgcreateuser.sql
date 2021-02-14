ALTER SESSION SET PLSQL_CCFLAGS = 'running_in_cloud:&running_in_cloud';

CREATE USER &username IDENTIFIED BY &password;

ALTER USER &username DEFAULT TABLESPACE &tablespace QUOTA UNLIMITED ON &tablespace;

ALTER USER &username TEMPORARY TABLESPACE &temptablespace;

GRANT CREATE SESSION TO &username;

GRANT CREATE TABLE to &username;

GRANT CREATE SEQUENCE to &username;

GRANT CREATE PROCEDURE to &username;

GRANT RESOURCE TO &username;

GRANT CREATE VIEW to &username;

GRANT ALTER SESSION TO &username;

GRANT EXECUTE ON dbms_lock TO &username;

GRANT ANALYZE ANY DICTIONARY to &username;

GRANT ANALYZE ANY to &username;

GRANT ALTER SESSION TO &username;

-- Following needed for concurrent stats collection

grant select on SYS.V_$PARAMETER to &username;

BEGIN
  $IF not $$running_in_cloud $THEN
      EXECUTE IMMEDIATE 'GRANT MANAGE SCHEDULER TO &username';
      EXECUTE IMMEDIATE 'GRANT MANAGE ANY QUEUE TO &username';
      EXECUTE IMMEDIATE 'GRANT CREATE JOB TO &username';
      $IF DBMS_DB_VERSION.VER_LE_10_2
      $THEN
        null;
      $ELSIF DBMS_DB_VERSION.VER_LE_11_2
      $THEN
        null;
      $ELSE
            -- The Following enables concurrent stats collection on Oracle Database 12c
            EXECUTE IMMEDIATE 'GRANT ALTER SYSTEM TO &username';
            DBMS_RESOURCE_MANAGER_PRIVS.GRANT_SYSTEM_PRIVILEGE(
                GRANTEE_NAME   => '&username',
                PRIVILEGE_NAME => 'ADMINISTER_RESOURCE_MANAGER',
                ADMIN_OPTION   => FALSE);
       $END
   $ELSE
      null;
   $END
END;

-- End;
