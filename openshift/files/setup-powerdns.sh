#!/bin/bash
#
set -e

sed -i 's/PEERDNS=.*/PEERDNS=no/' /etc/sysconfig/network-scripts/ifcfg-eth0

echo 'nameserver 8.8.8.8' > /etc/resolv.conf
yum -y install epel-release yum-plugin-priorities
curl -o /etc/yum.repos.d/powerdns-auth-40.repo https://repo.powerdns.com/repo-files/centos-auth-40.repo

yum -y install mariadb-server mariadb pdns pdns-backend-mysql bind-utils

systemctl enable mariadb.service
systemctl start mariadb.service

cat /tmp/powerdns_schema.sql | mysql
cp /tmp/pdns.conf /etc/pdns/pdns.conf
systemctl enable pdns.service
systemctl start pdns.service

sed -i 's/PEERDNS=.*/PEERDNS=yes/' /etc/sysconfig/network-scripts/ifcfg-eth0
service network restart
