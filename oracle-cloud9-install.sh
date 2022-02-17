#!/bin/bash
# should be run as user oracle
# after install-client-cloud9.sh - or as part of it
#
set +x
echo "======= Oracle software get to /home/oracle/software"
cd /home/oracle
mkdir software
cd software
echo "======= swingbench get to /home/oracle/software"
wget -q https://github.com/domgiles/swingbench-public/releases/download/production/swingbenchlatest.zip
unzip -qq swingbenchlatest.zip
sudo chown -R oracle.oinstall *
sudo chmod -R 755 *.sh

#rsp=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Oracle,Values=19c" | jq -r .Reservations[].Instances[].PrivateIpAddress)
#echo "Server:  $rsp"
#echo "$rsp oraclelinux" >> /etc/hosts