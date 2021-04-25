#!/bin/bash
set +x
date >> /tmp/myinstall.log
echo "git clone" >> /tmp/myinstall.log
yum install -y git
mkdir /software
cd /software
git clone https://github.com/awsandy/oracle-rds.git
cd oracle-rds
chmod 755 *.sh
echo "install" >> /tmp/myinstall.log
./install-client.sh >> /tmp/myinstall.log
echo "user data done" >> /tmp/myinstall.log