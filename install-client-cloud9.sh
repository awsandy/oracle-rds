#!/bin/bash
set +x
# ------  resize OS disk -----------

# Specify the desired volume size in GiB as a command-line argument. If not specified, default to 20 GiB.
VOLUME_SIZE=${1:-32}

# Get the ID of the environment host Amazon EC2 instance.
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data//instance-id)

# Get the ID of the Amazon EBS volume associated with the instance.
VOLUME_ID=$(aws ec2 describe-instances \
  --instance-id $INSTANCE_ID \
  --query "Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId" \
  --output text)

# Resize the EBS volume.
aws ec2 modify-volume --volume-id $VOLUME_ID --size $VOLUME_SIZE

# Wait for the resize to finish.
while [ \
  "$(aws ec2 describe-volumes-modifications \
    --volume-id $VOLUME_ID \
    --filters Name=modification-state,Values="optimizing","completed" \
    --query "length(VolumesModifications)"\
    --output text)" != "1" ]; do
sleep 1
done

if [ $(readlink -f /dev/xvda) = "/dev/xvda" ]
then
  # Rewrite the partition table so that the partition takes up all the space that it can.
  sudo growpart /dev/xvda 1
 
  # Expand the size of the file system.
  sudo resize2fs /dev/xvda1

else
  # Rewrite the partition table so that the partition takes up all the space that it can.
  sudo growpart /dev/nvme0n1 1

  # Expand the size of the file system.
  # sudo resize2fs /dev/nvme0n1p1 #(Amazon Linux 1)
  sudo xfs_growfs /dev/nvme0n1p1 #(Amazon Linux 2)
fi

sudo yum install -q -y wget smartmontools deltarpm jq nmap
#echo "SSM agent"
#wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
#yum install -y amazon-ssm-agent.rpm
#systemctl enable amazon-ssm-agent
#systemctl start amazon-ssm-agent
#systemctl status amazon-ssm-agent
echo "======= yum compat"
sudo yum install -y compat-libcap1.x86_64 gcc.x86_64 gcc-c++.x86_64 glibc.i686 glibc.x86_64 glibc-devel.i686 glibc-devel.x86_64 ksh compat-libstdc++-33 libgcc.i686 libstdc++.i686 libstdc++-devel.i686 libstdc++-devel.x86_64 libXi.i686 libXi.x86_64 libXtst.i686 libXtst.x86_64
#firewall-cmd --add-port=3389/tcp --permanent
#systemctl stop firewalld
#systemctl disable firewalld
#sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
#setenforce Permissive
#hostnamectl set-hostname client.local
sudo groupadd oinstall
sudo groupadd dba
sudo useradd -g oinstall -G dba oracle
sudo usermod -aG wheel oracle
sudo  echo -e "linuxpassword0182\nlinuxpassword0182" | passwd oracle
sudo echo "fs.aio-max-nr = 1048576" >> /etc/sysctl.conf
sudo echo "fs.file-max = 6815744" >> /etc/sysctl.conf
sudo echo "kernel.shmall = 2097152" >> /etc/sysctl.conf
sudo echo "kernel.shmmax = 8329226240" >> /etc/sysctl.conf
sudo echo "kernel.shmmni = 4096" >> /etc/sysctl.conf
sudo echo "kernel.sem = 250 32000 100 128" >> /etc/sysctl.conf
sudo echo "net.ipv4.ip_local_port_range = 9000 65500" >> /etc/sysctl.conf
sudo echo "net.core.rmem_default = 262144" >> /etc/sysctl.conf
sudo echo "net.core.rmem_max = 4194304" >> /etc/sysctl.conf
sudo echo "net.core.wmem_default = 262144" >> /etc/sysctl.conf
sudo echo "net.core.wmem_max = 1048586" >> /etc/sysctl.conf
sudo sysctl -p > /dev/null
sudo sysctl -a > /dev/null
sudo echo "oracle soft nproc 2047" >> /etc/security/limits.conf
sudo echo "oracle hard nproc 16384" >> /etc/security/limits.conf
sudo echo "oracle soft nofile 1024" >> /etc/security/limits.conf
sudo echo "oracle hard nofile 65536" >> /etc/security/limits.conf
sudo echo "oracle soft stack 10240" >> /etc/security/limits.conf
sudo echo "oracle hard stack 32768" >> /etc/security/limits.conf
echo "aws cli"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -qq awscliv2.zip
./aws/install

date
echo "======= X11 mate "
sudo which  amazon-linux-extras
sudo amazon-linux-extras install -y mate-desktop1.x
sudo echo "PREFERRED=/usr/bin/mate-session" > /etc/sysconfig/desktop

sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

sudo systemctl set-default graphical.target
echo "======= xrdp"
sudo yum -y install xrdp tigervnc-server
#yum -y install xrdp
sudo systemctl start xrdp
sudo systemctl enable xrdp
sudo netstat -antup | grep xrdp
date

echo "======= Corretto Java"

sudo rpm --import https://yum.corretto.aws/corretto.key 
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo yum install -y java-15-amazon-corretto-devel

echo "======= Oracle software get to /software"
cd /home/ec2-user/environment
mkdir software
cd software
echo "======= swingbench get to /software"
wget -q https://github.com/domgiles/swingbench-public/releases/download/production/swingbenchlatest.zip
echo "======= SCT get to /software"
wget -q https://s3.amazonaws.com/publicsctdownload/Fedora/aws-schema-conversion-tool-1.0.latest.zip
#wget -q https://www.oracle.com/database/technologies/jdbc-ucp-122-downloads.html
echo "======= get oracle inst client & sqlplus"
#aws s3 cp s3://oracle-swingbench/clients/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm  --quiet
aws s3 cp s3://oracle-swingbench/clients/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm
aws s3 cp s3://oracle-swingbench/clients/oracle-instantclient19.14-sqlplus-19.14.0.0.0-1.x86_64.rpm oracle-instantclient19.14-sqlplus-19.14.0.0.0-1.x86_64.rpm
echo "======= install oracle inst basic client"
sudo  yum install -y oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm
sudo  yum install -y oracle-instantclient19.14-sqlplus-19.14.0.0.0-1.x86_64.rpm
sudo  chown oracle.oinstall *
#chmod -R 755 /software/*.sh
sudo ls software
#echo "======= Oracle clinstall-1 - swingbench" 
#sudo -u oracle -- sh -c "/software/oracle-rds/clinstall-1.sh"
echo "X11 stuff again ......"cd
sudo amazon-linux-extras install -y mate-desktop1.x
sudo echo "PREFERRED=/usr/bin/mate-session" > /etc/sysconfig/desktop
#rsp=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Oracle,Values=19c" | jq -r .Reservations[].Instances[].PrivateIpAddress)
#echo "Server:  $rsp"
#echo "$rsp oraclelinux" >> /etc/hosts
date

