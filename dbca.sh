cd $ORACLE_HOME
./dbca -silent -createDatabase -templateName
General_Purpose.dbc -gdbName orcl -sid orcl -sysPassword dbpw010170
-systemPassword password -sysmanPassword password -dbsnmpPassword password
-emConfiguration LOCAL -storageType FS 
-datafileJarLocation $ORACLE_HOME/assistants/dbca/templates 
-characterset AL32UTF8 -obfuscatedPasswords false -sampleSchema
true -asmSysPassword password"