#!/bin/bash

cd ~
rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm
yum -y install git
git clone http://github.com/seanhess/centos.git
echo "Bootstrapped"
