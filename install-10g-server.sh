#!/bin/bash
set +x
date
yum install -q -y wget smartmontools deltarpm jq nmap
echo "SSM agent"
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
yum install -q -y amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
systemctl status amazon-ssm-agent
echo "======= yum compat" 
yum install -y binutils gcc gcc-c++ glibc-devel libgcc libstdc++-devel libstdc++ make compat-db
yum install -y binutils.x86_64 compat-libcap1.x86_64 gcc.x86_64 gcc-c++.x86_64 glibc.i686 glibc.x86_64 glibc-devel.i686 glibc-devel.x86_64 ksh compat-libstdc++-33 libaio.i686 libaio.x86_64 libaio-devel.i686 libaio-devel.x86_64 libgcc.i686 libgcc.x86_64 libstdc++.i686 libstdc++.x86_64 libstdc++-devel.i686 libstdc++-devel.x86_64 libXi.i686 libXi.x86_64 libXtst.i686 libXtst.x86_64 make.x86_64 sysstat.x86_64 zip unzip
#firewall-cmd --add-port=3389/tcp --permanent
#systemctl stop firewalld
#systemctl disable firewalld
#sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
#setenforce Permissive
hostnamectl set-hostname oracle.local
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
echo "======= aws cli" 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -qq awscliv2.zip
./aws/install
echo "======= Swap"
dd if=/dev/zero of=/swapfile bs=1048576 count=8192
mkswap /swapfile
chmod 0600 /swapfile
echo "/swapfile   swap swap  defaults  0 0" >> /etc/fstab
#systemctl daemon-reload
swapon /swapfile
free -h  
date
echo "======= X11" 
date 
#yum install -y xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-apps
#yum install "@X Window System" xorg-x11-xauth xorg-x11-fonts-* xorg-x11-utils –y
echo "======= epel rpm"
#rpm -U https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#yum groupinstall -y "Xfce"
echo "======= group install X Windows"
#yum groupinstall -q -y 'X Window System' 'GNOME'
yum  install -y  switchdesk
yum groupinstall -q -y “X Window System”
echo "======= group install GNOME"
yum groupinstall -q -y “GNOME Desktop Environment”
echo "======= group install XFCE"
yum  groupinstall -q -y  XFCE-4.4

#echo "PREFERRED=/usr/bin/mate-session" > /etc/sysconfig/desktop

echo "======= xrdp" 
date 

yum -q -y install --enablerepo=epel xrdp vnc-server
echo "VNCSERVERS="1:oracle" > /etc/sysconfig/vncservers
printf "VNCSERVERARGS[1]=\"-geometry 640x480\"" > /etc/sysconfig/vncservers

echo "======= start xrdp"
chkconfig vncserver on
#chkconfig --levels 5 xrdp on
chkconfig xrdp on
service vncserver start
service xrdp start
netstat -antup | grep xrdp 
echo "======= Oracle section" 
date 
echo "======= Oracle pre-req rpm" 
#yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-19c-1.0-1.el7.x86_64.rpm
#echo "======= xfce4-session" > /home/oracle/.Xclients
#chown oracle.oinstall /home/oracle/.Xclients
mkdir /u01
mkdir /u02
mkfs -t xfs /dev/nvme1n1
mkfs -t xfs /dev/nvme2n1

echo "/dev/nvme1n1 /u01 xfs  defaults   0 0" >> /etc/fstab
echo "/dev/nvme2n1 /u02 xfs  defaults   0 0" >> /etc/fstab
mount /u01
mount /u02

chown -R oracle:oinstall /u01
chmod -R 775 /u01
chmod g+s /u01
chown -R oracle:oinstall /u02
chmod -R 775 /u02
chmod g+s /u02

mkdir -p /u01/app/oracle/product/19.3.0/dbhome_1
mkdir -p /u02/oradata
chown -R oracle:oinstall /u01 /u02
chmod -R 775 /u01 /u02
date 
echo "======= Oracle software download to /software" 
mkdir /software
cd /software
wget -q https://github.com/domgiles/swingbench-public/releases/download/production/swingbenchlatest.zip
aws s3 cp s3://oracle-swingbench/10g-linux/oracle10g.zip 10g.zip --quiet
aws s3 cp s3://oracle-swingbench/java-linux/jre-8u281-linux-x64.rpm jre-8u281-linux-x64.rpm  --quiet
echo "======= JRE v8 SE" 
yum install -q -y jre-8u281-linux-x64.rpm
chown oracle.oinstall /software/*
chmod 755 /software/*.sh
ls /software 
date 
echo "======= Oracle dbinstall 1" 
#sudo -u oracle -- sh -c "/software/oracle-rds/dbinstall-10g-1.sh"
#echo "======= dbinstall 1 done ....." 
#date 
#echo "======= Manaual Oracle root.sh " 
#/u01/app/oraInventory/orainstRoot.sh
#echo -e "\n" | /u01/app/oracle/product/19.3.0/dbhome_1/root.sh

#echo "======= Oracle dbinstall 2" 
#date 
#sudo -u oracle -- sh -c "/software/oracle-rds/dbinstall-10g-2.sh"
#echo "======= dbinstall 2 done ....." 
#date 
##cat /home/oracle/dbinstall.txt 
echo "======= Finished 10g server install .. at ======== "
date 
