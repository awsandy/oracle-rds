#!/bin/bash
set +x
cd ~/environment
sudo yum install -q -y wget smartmontools deltarpm jq nmap
sudo yum reinstall python3-pip -y
# Increase the disk size to 32GB
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

$(readlink -f /dev/xvda) 2> /dev/null
if [[ $? -eq 0 ]];then
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

echo "Install aws cli v2"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -qq awscliv2.zip
sudo ./aws/install
rm -f awscliv2.zip

date
echo "======= X11 mate desktop install - this takes a few minutes ..."
sudo amazon-linux-extras install -y mate-desktop1.x > /dev/null

sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -q

sudo systemctl set-default graphical.target
echo "======= xrdp"
sudo yum -y install xrdp tigervnc-server -q 2> /dev/null
#yum -y install xrdp
sudo systemctl start xrdp
sudo systemctl enable xrdp
sudo netstat -antup | grep 3389

echo "X11 stuff again ......"
sudo amazon-linux-extras install -y mate-desktop1.x
echo "PREFERRED=/usr/bin/mate-session" > desktop
sudo cp desktop /etc/sysconfig/desktop
echo "install chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -q
sudo yum install google-chrome-stable_current_*.rpm -y -q 
echo "DB Beaver"
wget https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm -q
sudo yum install dbeaver-ce-latest-stable.x86_64.rpm  -y -q 2> /dev/null
#echo "Lens"
#wget https://api.k8slens.dev/binaries/Lens-5.3.4-latest.20220120.1.x86_64.rpm -q
#sudo yum  install Lens-5.3.4-latest.20220120.1.x86_64.rpm  -y -q 2> /dev/null
echo "VS Code"
wget -O vscode.rpm https://go.microsoft.com/fwlink/?LinkID=760867 -q
sudo yum install vscode.rpm  -y -q 2> /dev/null
sudo cat /etc/sysconfig/desktop


echo "======= yum compat"
sudo yum install -y compat-libcap1.x86_64 gcc.x86_64 gcc-c++.x86_64 glibc.i686 glibc.x86_64 glibc-devel.i686 glibc-devel.x86_64 ksh compat-libstdc++-33 libgcc.i686 libstdc++.i686 libstdc++-devel.i686 libstdc++-devel.x86_64 libXi.i686 libXi.x86_64 libXtst.i686 libXtst.x86_64

sudo groupadd oinstall
sudo groupadd dba
sudo useradd -g oinstall -G dba oracle
sudo usermod -aG wheel oracle
sudo -u root -- sh -c "/home/ec2-user/environment/oracle-rds/ora-sysctl.sh"



echo "======= Corretto Java"

sudo rpm --import https://yum.corretto.aws/corretto.key 
sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo yum install -y java-15-amazon-corretto-devel -q

#echo "======= SCT get to /software"
#wget -q https://s3.amazonaws.com/publicsctdownload/Fedora/aws-schema-conversion-tool-1.0.latest.zip
#wget -q https://www.oracle.com/database/technologies/jdbc-ucp-122-downloads.html
echo "======= get oracle inst client & sqlplus"
#aws s3 cp s3://oracle-swingbench/clients/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm  --quiet
aws s3 cp s3://oracle-swingbench/clients/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm
#aws s3 cp s3://oracle-swingbench/clients/oracle-instantclient19.14-sqlplus-19.14.0.0.0-1.x86_64.rpm oracle-instantclient19.14-sqlplus-19.14.0.0.0-1.x86_64.rpm
echo "======= install oracle inst basic client"
sudo  yum install -y oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm
#sudo  yum install -y oracle-instantclient19.14-sqlplus-19.14.0.0.0-1.x86_64.rpm

sudo chown oracle.oinstall oracle-cloud9-install.sh
sudo chmod 755 oracle-cloud9-install.sh


sudo -u oracle -- sh -c "/home/ec2-user/environment/oracle-rds/oracle-cloud9-install.sh"
#rsp=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Oracle,Values=19c" | jq -r .Reservations[].Instances[].PrivateIpAddress)
#echo "Server:  $rsp"
#echo "$rsp oraclelinux" >> /etc/hosts


echo "look in /usr/share/applications"
echo "Instance ID = $INSTANCE_ID"
