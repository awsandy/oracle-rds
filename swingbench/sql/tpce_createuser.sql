ALTER SESSION SET PLSQL_CCFLAGS = 'running_in_cloud:&running_in_cloud';

CREATE USER &username IDENTIFIED BY &password;

ALTER USER &username DEFAULT TABLESPACE &tablespace QUOTA UNLIMITED ON &tablespace;

ALTER USER &username QUOTA UNLIMITED ON &indextablespace;

ALTER USER &username TEMPORARY TABLESPACE TEMP;

GRANT CREATE SESSION TO &username;

GRANT CREATE TABLE TO &username;

GRANT CREATE SEQUENCE TO &username;

GRANT CREATE PROCEDURE TO &username;

GRANT RESOURCE TO &username;

GRANT CREATE VIEW TO &username;

GRANT ALTER SESSION TO &username;

GRANT EXECUTE ON DBMS_LOCK TO &username;

GRANT CREATE VIEW TO &username;

GRANT ANALYZE ANY DICTIONARY TO &username;

GRANT ANALYZE ANY TO &username;

GRANT ALTER SESSION TO &username;

GRANT SELECT ON SYS.V_$PARAMETER TO &username;

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

