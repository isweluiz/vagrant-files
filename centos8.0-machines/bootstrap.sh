#!/bin/bash

# Enable ssh password authentication
echo "[TASK 1] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Enable root ssh login
echo "[TASK 2] Enable ssh root login"
sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

systemctl reload sshd

# Set Root password
echo "[TASK 3] Set root password"
echo root:blogisweluiz | chpasswd

echo "[TASK 4] Set timezone"
timedatectl set-timezone 'Europe/Dublin'

echo "[TASK 5] Clean package cache"
dnf clean all 
#rm -rf /var/cache/yum
#sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
#sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

echo "[TASK 6] Clean package cache & update"
dnf update -y 
dnf install python3.9 -y
dnf install vim -y

