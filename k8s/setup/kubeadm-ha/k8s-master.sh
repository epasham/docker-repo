#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail



echo '============================================================'
echo '====================Disable selinux and firewalld==========='
echo '============================================================'
if [ $(getenforce) = "Enabled" ]; then
setenforce 0
fi
systemctl disable firewalld
systemctl stop firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
echo "Disable selinux and firewalld success!"

