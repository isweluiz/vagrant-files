#!/bin/bash


echo "[TASK 2] Install Ansible 2.8"
python3 -m pip install --user ansible==2.9 
sudo ln -s /usr/local/bin/ansible /usr/bin/ansible

echo "[TASK 2] Install Git"
yum install git -y