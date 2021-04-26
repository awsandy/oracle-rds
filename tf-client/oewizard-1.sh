#!/bin/bash
. ~/.bash_profile
echo "oewizard 2 start"
date
cd ~
export ORACLE_SID=orcl

db1=$(aws rds describe-db-instances --region eu-west-2 --db-instance-identifier dwp-demo-ha-az2 --query "DBInstances[].Endpoint.Address" | jq -r .[])
nmap $db1 -Pn -p 1521 | grep open
echo "swingbench oewizard"
date

dbp=$(aws secretsmanager get-secret-value --region eu-west-2 --secret-id db-creds | jq -r .SecretString | jq -r .password)

# drop -cl run in char mode 
#./oewizard -dbap manager -u soe -p soe -cl -cs //localhost/plorcl -ts SOE -drop
# 
#
# get db hostname
# aws rds 
#
# create
cd ~/swingbench/bin
./oewizard  -dba admin -dbap $dbp -u soe -p soe -cl -cs //$db1/orcl -ts SOE -scale 1 -create -tc 8 -v
if [ $? -ne 0 ]; then
    echo "ERROR:  oewizard non zero exit code "
fi
# 1 thread 2m 19 - 2 threads 3m 52 - 4 threads 2m 42
echo "Finished oewizard"
date
