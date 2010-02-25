#!/bin/bash

# Usage: From linode stack script 
#   source <ssinclude StackScriptID=168>

# Usage: From new system on the command line
#   rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm
#   yum -y install git
#   git clone http://github.com/seanhess/centos.git
#   source centos/centos_library.sh

# You can then call any function like: 
#   system_update
#   www_user seanhess somepassword

# Dependencies - make sure they only run once
Ran=1
New=0
ruby19=$New
www_group=$New

# update packages and install epel repo
function system_update {
    yum -y update
    rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm
    echo "System Updated"
}

# a whole bunch of yum stuff
function install_basics {
    system_update
    yum -y install wget curl rsync git sudo
    yum -y install gcc gcc-c++ gettext-devel expat-devel curl-devel zlib-devel openssl-devel perl cpio 
    echo "Installed Basics"
}

function ruby19 {
    if [ $ruby19 == $Ran ]; then return; fi
        
    # we need gcc, gcc-c++, wget
    install_basics
    
    mkdir ~/sources
    cd ~/sources
    wget "ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.1-p378.tar.gz"
    tar zxvf ruby-1.9.1-p378.tar.gz
    cd ruby-1.9.1-p378
    ./configure
    make
    make install
    
    echo "Ruby 1.9 installed"
    ruby19=$Ran
}

# Create a user and add them to the www group?
function www_user {
    create_web_group
    
    username=$1
    password=$2
    
    useradd -m -p $password $username
    
    echo "User $username created"
}

function www_group {
    if [ $www_group == $Ran ]; then return; fi
    groupadd www
    chown -R :www /var/www
    echo "www group created"
    www_group=$Ran
}

function nginx {
    yum -y install pcre-devel zlib-devel openssl-devel
    
    mkdir ~/sources
    cd ~/sources
}

# http://sifumoraga.blogspot.com/2009/11/installing-couchdb-on-centos5-system.html
function couchdb {
    install_basics
    yum -y install ncurses-devel openssl-devel icu libicu-devel js js-devel curl-devel erlang erlang-devel libtool
    yum -y install couchdb
    
}
