#!/bin/bash
. ~/.bash_profile
echo "dbinstall 2 start"
date
cd ~
export ORACLE_SID=orcl

echo "Starting silent dbca" 
date 
$ORACLE_HOME/bin/dbca -silent -createDatabase -responseFile /software/oracle-rds/dbca_orcl-1.rsp 
if [ $? -ne 0 ]; then
    echo "ERROR:  dbca non zero exit code $?" 
fi
lsnrctl start
if [ $? -ne 0 ]; then
    echo "ERROR:  lsnr non zero exit code $?" 
fi
echo "Finished silent dbca" 
date 
echo "unpacking swingbench" 
cd ~
unzip -qq /software/swingbenchlatest.zip
cd swingbench/bin
ls owiz*

echo "Opening db" 
echo "startup mount;" | sqlplus / as sysdba
echo "alter database open;" | sqlplus / as sysdba
#echo "ALTER PLUGGABLE DATABASE plorcl OPEN READ WRITE;" | sqlplus / as sysdba
echo "CREATE TEMPORARY TABLESPACE temp2 TEMPFILE 'temp2.dbf' SIZE 2000m;" | sqlplus / as sysdba
echo "alter user sys identified by manager;" | sqlplus / as sysdba
echo "alter user system identified by manager;" | sqlplus / as sysdba
echo "ALTER DATABASE DEFAULT TEMPORARY TABLESPACE temp2;" | sqlplus / as sysdba
echo "SELECT * FROM dba_temp_free_space;" | sqlplus / as sysdba


echo "sleep 180 for lsnrctl"
sleep 180
lsnrctl status | grep orcl
if [ $? -ne 0 ]; then
    echo "ERROR:  lsnr no orcl in status $? "
fi

echo "swingbench oewizard"
date
# drop -cl run in char mode 
#./oewizard -dbap manager -u soe -p soe -cl -cs //localhost/plorcl -ts SOE -drop
# create
cd ~/swingbench/bin
./oewizard  -dbap manager -u soe -p soe -cl -cs //localhost/orcl -ts SOE -scale 1 -df /u02/oradata/soe.dbf -create
if [ $? -ne 0 ]; then
    echo "ERROR:  oewizard non zero exit code "
fi
# 1 thread 2m 19 - 2 threads 3m 52 - 4 threads 2m 42
echo "Finished oewizard"
date
# inflate data
#./sbutil -u soe -p soe  -cs //localhost/plorcl -soe parallel 12 -dup 4
echo "listener status"
lsnrctl status
echo "dbinstall 2 done"
date