#!/bin/bash
set +x
date
echo "======= X11" 
date 
#yum install -y xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-apps
#yum install "@X Window System" xorg-x11-xauth xorg-x11-fonts-* xorg-x11-utils –y
#echo "======= epel rpm"
#rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#yum groupinstall -y "Xfce"
#echo "======= group install MATE"
# causes failure
#yum groupinstall -y "MATE Desktop"
#echo "PREFERRED=/usr/bin/mate-session" > /etc/sysconfig/desktop
echo "======= group install GNome"
yum groupinstall -y "Server with GUI"
#yum groupinstall -y 'X Window System' 'GNOME'

systemctl set-default graphical.target
systemctl default
echo "======= xrdp" 
date 
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm
yum  -y install xrdp tigervnc-server
#yum -y install xrdp
echo "======= start xrdp"
systemctl start xrdp
systemctl enable xrdp
netstat -antup | grep xrdp 
firewall-cmd --add-port=3389/tcp --permanent
systemctl stop firewalld
systemctl disable firewalld

