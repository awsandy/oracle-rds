https://catalog.us-east-1.prod.workshops.aws/v2/workshops/2300137e-f2ac-4eb9-a4ac-3d25026b235f/en-US/lab-1-sdk-ingest/1-kinesis-sdk/1-2-working-with-sdk


put record (sum bytes) - if stream is getting data from Oracle

Must create a unified audit policy first:

https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/configuring-audit-policies.html#GUID-D522F093-3B4C-40EA-B1FE-EB604F55E689



AUDIT POLICY ORA_LOGON_FAILURES WHENEVER NOT SUCCESSFUL;

AUDIT POLICY ORA_CIS_RECOMMENDATIONS;

AUDIT POLICY ORA_SECURECONFIG;