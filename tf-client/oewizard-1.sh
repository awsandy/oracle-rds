#!/bin/bash
. ~/.bash_profile
echo "oewizard 2 start"
date
cd ~
export ORACLE_SID=orcl
cd ~/swingbench/bin
dbp=$(aws secretsmanager get-secret-value --region eu-west-2 --secret-id db-config | jq -r .SecretString | jq -r .password)
db1=$(aws rds describe-db-instances --region eu-west-2 --db-instance-identifier dwp-demo-ha1-az2 --query "DBInstances[].Endpoint.Address" | jq -r .[])
db2=$(aws rds describe-db-instances --region eu-west-2 --db-instance-identifier dwp-demo-ha2-az2 --query "DBInstances[].Endpoint.Address" | jq -r .[])
db3=$(aws rds describe-db-instances --region eu-west-2 --db-instance-identifier dwp-demo-single --query "DBInstances[].Endpoint.Address" | jq -r .[])

if [ $db1 != "" ];then 
    nmap $db1 -Pn -p 1521 | grep open
    echo "swingbench oewizard"
    date
   
    time ./oewizard  -dba admin -dbap $dbp -u soe -p soe -cl -cs //$db1/orcl -ts SOE -scale 32 -create -tc 8 -v 
    if [ $? -ne 0 ]; then
        echo "ERROR:  oewizard non zero exit code "
    fi
fi


if [ $db2 != "" ];then 
    nmap $db2 -Pn -p 1521 | grep open
    echo "swingbench oewizard"
    date

    ./oewizard  -dba admin -dbap $dbp -u soe -p soe -cl -cs //$db2/orcl -ts SOE -scale 32 -create -tc 8 -v 
    if [ $? -ne 0 ]; then
        echo "ERROR:  oewizard non zero exit code "
    fi
fi


if [ $db3 != "" ];then 
    nmap $db3 -Pn -p 1521 | grep open
    echo "swingbench oewizard"
    date

    cd ~/swingbench/bin
    ./oewizard  -dba admin -dbap $dbp -u soe -p soe -cl -cs //$db3/orcl -ts SOE -scale 32 -create -tc 8 -v 
    if [ $? -ne 0 ]; then
        echo "ERROR:  oewizard non zero exit code "
    fi
fi

# 1 thread 2m 19 - 2 threads 3m 52 - 4 threads 2m 42
echo "Finished oewizard"
date
# 32GB ~ 40m
