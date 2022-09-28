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
#dnf update -y 
dnf install python3.9 jq vim -y

#echo "[TASK 7] Configure ssh-pub key"
#mkdir /root/.ssh/
#echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQLe82dDBHegwVx3eXcTvMR/irXf2lJ9SnIiCaZr7FL/ve8A5S346m5mpPwg8Qi8EFPIkxJYnOTSSSb1zvSiQt5yVF2xUuN3aWS+9xfDrR0FlJA++IgPee5UjjQaHHJ9MZdQ4SyGUq7XyL8yJlhiGmdMMXfga3TyjWmNuQJy+wOItsCyBGAlhR8IEA5lOVAA81Hg+GV5mW3/SQZ3iJrXapfFlO+EPf62/QSqn4QzdkIGMQl4PDYhnukVa45Xf8fzfmKzS6Zz0IJ9EoBo2xDM0LFIKRNi5uwcHTRII8r1G5yikZFiJLNobcKWXZPwkc4uJPg4PQdO3CNIkol4OvbaEOzNGoGj7R75OqFzczCr0cLl1wc0Vtb8fhhbCek/ALFj7d5tdE6qNxxlJCk+Us6eQCZow+SikQ7QveYIoURkkOthpUDtZuPbcHC/KN3T2T+D5umqADf0xDyxXntnp1uPNNzq6GgYMfcjrFJ3lY5yIPhtyyPp3qiRW3qx4uKRKjxe5tWfx53BeQce4K7HowETG2emua9ox86tA7Ch0fszRDxQ/CGsw9Fl8fPXTUjQK/mp98b9LMat1JBtXVZx8TVHbd/d3ec9k7XSj203egM+F2BzGZDQPrtLqGAC0g7pHiHcAuGMZErYJCZ5CBhPgHr9usqEIcQEEKtZnj10jOCga15Ezw== Vagrant machines - Lab" > /root/.ssh/authorized_keys

