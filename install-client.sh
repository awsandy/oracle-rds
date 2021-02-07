#!/bin/bash
set +x
date
yum install -q -y wget smartmontools deltarpm jq nmap
echo "SSM agent"
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
yum install -q -y amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
#systemctl status amazon-ssm-agent
echo "======= yum compat"
yum install -q -y compat-libcap1.x86_64 gcc.x86_64 gcc-c++.x86_64 glibc.i686 glibc.x86_64 glibc-devel.i686 glibc-devel.x86_64 ksh compat-libstdc++-33 libgcc.i686 libstdc++.i686 libstdc++-devel.i686 libstdc++-devel.x86_64 libXi.i686 libXi.x86_64 libXtst.i686 libXtst.x86_64
firewall-cmd --add-port=3389/tcp --permanent
systemctl stop firewalld
systemctl disable firewalld
sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
setenforce Permissive
hostnamectl set-hostname client.local
groupadd oinstall
groupadd dba
useradd -g oinstall -G dba oracle
usermod -aG wheel oracle
echo -e "linuxpassword0182\nlinuxpassword0182" | passwd oracle
echo "fs.aio-max-nr = 1048576" >> /etc/sysctl.conf
echo "fs.file-max = 6815744" >> /etc/sysctl.conf
echo "kernel.shmall = 2097152" >> /etc/sysctl.conf
echo "kernel.shmmax = 8329226240" >> /etc/sysctl.conf
echo "kernel.shmmni = 4096" >> /etc/sysctl.conf
echo "kernel.sem = 250 32000 100 128" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 9000 65500" >> /etc/sysctl.conf
echo "net.core.rmem_default = 262144" >> /etc/sysctl.conf
echo "net.core.rmem_max = 4194304" >> /etc/sysctl.conf
echo "net.core.wmem_default = 262144" >> /etc/sysctl.conf
echo "net.core.wmem_max = 1048586" >> /etc/sysctl.conf
sysctl -p > /dev/null
sysctl -a > /dev/null
echo "oracle soft nproc 2047" >> /etc/security/limits.conf
echo "oracle hard nproc 16384" >> /etc/security/limits.conf
echo "oracle soft nofile 1024" >> /etc/security/limits.conf
echo "oracle hard nofile 65536" >> /etc/security/limits.conf
echo "oracle soft stack 10240" >> /etc/security/limits.conf
echo "oracle hard stack 32768" >> /etc/security/limits.conf
echo "aws cli"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -qq awscliv2.zip
./aws/install

date
echo "======= X11 mate "
which  amazon-linux-extras
amazon-linux-extras install -y mate-desktop1.x
echo "PREFERRED=/usr/bin/mate-session" > /etc/sysconfig/desktop


rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm


systemctl set-default graphical.target
echo "======= xrdp"
yum -q -y install xrdp tigervnc-server
#yum -y install xrdp
systemctl start xrdp
systemctl enable xrdp
netstat -antup | grep xrdp
date

echo "======= Corretto Java"

sudo rpm --import https://yum.corretto.aws/corretto.key 
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo yum install -y java-15-amazon-corretto-devel

echo "======= Oracle software get to /software"
mkdir /software
cd /software
wget -q https://github.com/domgiles/swingbench-public/releases/download/production/swingbenchlatest.zip
aws s3 cp s3://oracle-swingbench/clients/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm  --quiet
yum install -q -y oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm
chown oracle.oinstall /software/*
chmod 755 /software/*.sh
ls /software
echo "======= Oracle clinstall 1" 
sudo -u oracle -- sh -c "/software/oracle-rds/clinstall-1.sh"
echo "X11 stuff again ......"
amazon-linux-extras install -y mate-desktop1.x
echo "PREFERRED=/usr/bin/mate-session" > /etc/sysconfig/desktop
rsp=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Oracle,Values=19c" | jq -r .Reservations[].Instances[].PrivateIpAddress)
echo "Server:  $rsp"
echo "$rsp oraclelinux" >> /etc/hosts
date

