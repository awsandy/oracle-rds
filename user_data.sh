#!/bin/bash
set +x
date >> /tmp/myinstall.log
pwd >> /tmp/myinstall.log
echo "SSM agent" >> /tmp/myinstall.log
echo "git" >> /tmp/myinstall.log
yum install -y git
mkdir /software
cd /software
git clone https://github.com/awsandy/oracle-rds.git
cd oracle-rds
chmod 755 *.sh
echo "install" >> /tmp/myinstall.log
./install.sh >> /tmp/myinstall.log
echo "done" >> /tmp/myinstall.log
