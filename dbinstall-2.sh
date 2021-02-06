echo "dbinstall 2 start" >> ~/dbinstall.txt
cd ~
echo "Starting silent dbca" >> ~/dbinstall.txt
$ORACLE_HOME/bin/dbca -silent -responseFile /software/oracle-rds/dbca_orcl-1.rcp
echo "Finished silent dbca" >> ~/dbinstall.txt
echo "unpacking swingbench" >> ~/dbinstall.txt
cd ~
unzip -qq /software/swingbenchlatest.zip
cd swingbench/bin
echo "swingbench oewizard" >> ~/dbinstall.txt
./oewizard -dbap ea96!qIVBTND -nopart -u soe -p soe -cl -cs //oracle.local/orcl -ts soe_tbs -create -dba system
# inflate data
#./sbutil -u soe -p soe  -cs //lab/martin -soe parallel 12 -dup 4
echo "listener" >> ~/dbinstall.txt
#lsnrctl start
echo "dbinstall 2 done" >> ~/dbinstall.txt