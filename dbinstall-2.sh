echo "dbinstall 2 start" >> ~/dbinstall.txt
cd ~
export ORACLE_SID=orcl

echo "Starting silent dbca" >> ~/dbinstall.txt
$ORACLE_HOME/bin/dbca -silent -createDatabase -responseFile /software/oracle-rds/dbca_orcl-1.rsp >> ~/dbinstall.txt
lsnrctl start >> ~/dbinstall.txt
echo "Finished silent dbca" >> ~/dbinstall.txt
echo "unpacking swingbench" >> ~/dbinstall.txt
cd ~
unzip -qq /software/swingbenchlatest.zip
cd swingbench/bin

echo "Opening db" >> ~/dbinstall.txt
echo "startup mount;" | sqlplus / as sysdba >> ~/dbinstall.txt
echo "alter database open;" | sqlplus / as sysdba >> ~/dbinstall.txt
#echo "ALTER PLUGGABLE DATABASE plorcl OPEN READ WRITE;" | sqlplus / as sysdba >> ~/dbinstall.txt
echo "CREATE TEMPORARY TABLESPACE temp2 TEMPFILE 'temp2.dbf' SIZE 2000m;" | sqlplus / as sysdba
echo "alter user sys identified by manager;" | sqlplus / as sysdba >> ~/dbinstall.txt
echo "alter user system identified by manager;" | sqlplus / as sysdba >> ~/dbinstall.txt
echo "ALTER DATABASE DEFAULT TEMPORARY TABLESPACE temp2;" | sqlplus / as sysdba >> ~/dbinstall.txt
echo "sleep 30 for lsnrctl" >> ~/dbinstall.txt
sleep 30
lsnrctl status >> ~/dbinstall.txt

echo "swingbench oewizard" >> ~/dbinstall.txt
# drop -cl run in char mode 
#./oewizard -dbap manager -u soe -p soe -cl -cs //localhost/plorcl -ts SOE -drop
# create
cd ~/swingbench/bin
./oewizard  -dbap manager -u soe -p soe -cl -cs //localhost/orcl -ts SOE -scale 1 -df /u02/oradata/soe.dbf -create >> ~/dbinstall.txt
# 1 thread 2m 19 - 2 threads 3m 52 - 4 threads 2m 42
 
# inflate data
#./sbutil -u soe -p soe  -cs //localhost/plorcl -soe parallel 12 -dup 4
echo "listener status" >> ~/dbinstall.txt
lsnrctl status >> ~/dbinstall.txt
echo "dbinstall 2 done" >> ~/dbinstall.txt