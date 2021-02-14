ALTER SESSION SET PLSQL_CCFLAGS = 'running_in_cloud:&running_in_cloud';

CREATE USER &username IDENTIFIED BY & password;

ALTER USER &username DEFAULT TABLESPACE & tablespace QUOTA UNLIMITED ON & tablespace;

ALTER USER &username QUOTA UNLIMITED ON &indextablespace;

ALTER USER &username TEMPORARY TABLESPACE &temptablespace;

GRANT CREATE SESSION TO &username;

GRANT CREATE TABLE to &username;

GRANT CREATE SEQUENCE to &username;

GRANT CREATE PROCEDURE to &username;

GRANT RESOURCE TO &username;

GRANT CREATE VIEW to &username;

GRANT ALTER SESSION TO &username;

GRANT EXECUTE ON dbms_lock TO &username;

GRANT CREATE VIEW to &username;

GRANT EXECUTE ON dbms_lock TO &username;

GRANT ANALYZE ANY DICTIONARY to &username;

GRANT ANALYZE ANY to &username;

GRANT ALTER SESSION TO &username;

grant select on SYS.V_$PARAMETER to &username;

BEGIN
    $IF not $$running_in_cloud $THEN
    EXECUTE IMMEDIATE 'GRANT ALTER SYSTEM TO &username';
    $
END
END;

-- End;

