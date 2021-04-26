#!/bin/bash
. ~/.bash_profile
echo "oewizard 2 start"
date
cd ~
export ORACLE_SID=orcl

db1=$(aws rds describe-db-instances --region eu-west-2 --db-instance-identifier dwp-demo-ha-az2 --query "DBInstances[].Endpoint.Address" | jq -r .[])

echo "swingbench oewizard"
date
# drop -cl run in char mode 
#./oewizard -dbap manager -u soe -p soe -cl -cs //localhost/plorcl -ts SOE -drop
# 
#
# get db hostname
# aws rds 
#
# create
cd ~/swingbench/bin
./oewizard  -dbap $1 -u soe -p soe -cl -cs //$db1/orcl -ts SOE -scale 1 -create
if [ $? -ne 0 ]; then
    echo "ERROR:  oewizard non zero exit code "
fi
# 1 thread 2m 19 - 2 threads 3m 52 - 4 threads 2m 42
echo "Finished oewizard"
date
