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
www=$New
nginx=$New
admin=$New

# update packages and install epel repo
function system_update {
    yum -y update
    epel_repo
    echo "System Updated"
}

function epel_repo {
    rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm
}

# a whole bunch of yum stuff
function install_basics {
    system_update
    epel_repo
    yum -y install wget curl rsync git sudo vim make which mlocate man vixie-cron readline-devel
    yum -y install gcc gcc-c++ gettext-devel expat-devel curl-devel zlib-devel openssl-devel perl cpio 
    yum -y install pinfo
    echo "Installed Basics"
}

function sources {
    mkdir ~/sources
    cd ~/sources
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

function create_user {
    username=$1
    password=$2
    
    useradd $username
    set_password $username $password
}

function set_password {
    username=$1
    password=$2
    
    echo $password > /tmp/password.txt
    passwd --stdin $username < /tmp/password.txt
    rm /tmp/password.txt
    
    echo "Set password for $username"
}

function set_group {
    username=$1
    group=$2
    
    usermod -aG $group $username
    echo "Added $username to $group"
}

function fix_path {
    username=$1
    path="$(home_directory $username)/.bash_profile"
    sed -i .old -e 's/^PATH=.*$/PATH=$HOME\/bin:\/sbin:\/usr\/local\/bin:\/usr\/local\/sbin:\/bin:\/usr\/bin:\/usr\/sbin/' $path
#    echo "alias sudo='sudo -E '"
}



# returns a users home directory
function home_directory {
    username=$1
    if [ $username == "root" ]; then
        echo "/root"
    else
        echo "/home/$username"
    fi
}

# Create a "www" deploy user with no password
# this automatically creates a www group as well
function www {
    if [ $www == $Ran ]; then return; fi
    useradd www
    mkdir -p /var/www
    chown -R www:www /var/www
    echo "User www created"
}

function admin_group {
    if [ $admin == $Ran ]; then return; fi
        
    groupadd admin
    echo "%admin        ALL=(ALL)       ALL" >> /etc/sudoers
    echo "created admin group"
}

function sudoer {
    admin_group
    username=$1
    usermod -aG admin $username
    echo "$username has sudo rights"
}

# Installs from source, but links things back in yum-style
# /etc/nginx
# /var/log/nginx
# /etc/init.d/nginx
# /usr/sbin/nginx
function nginx {
    if [ $nginx == $Ran ]; then return; fi
        
    install_basics
    
    yum -y install pcre-devel zlib-devel openssl-devel
    
    # Installs the service script, puts things in the right places
    yum -y install nginx
    
    # Install the full version of nginx
    mkdir ~/sources
    cd ~/sources
    wget http://nginx.org/download/nginx-0.7.65.tar.gz
    tar zxvf nginx-0.7.65.tar.gz
    cd nginx-0.7.65
    ./configure --with-http_ssl_module
    make
    make install
    
    # Now link it in the right place
    mv /usr/sbin/nginx /usr/sbin/nginx.old
    ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx
    
    echo "Nginx installed"
    nginx=$Ran
}

function curl {
    sources
    wget http://curl.haxx.se/download/curl-7.20.0.tar.gz -O curl.tar.gz
    tar zxvf curl.tar.gz
    cd curl-7.20.0
    ./configure
    make
    make install
}

# http://sifumoraga.blogspot.com/2009/11/installing-couchdb-on-centos5-system.html
# Needs curl > 7.18
# http://porteightyeight.com/2009/06/12/installing-couchdb-centos-5-linux/
function couchdb {
    epel_repo
    yum -y install ncurses-devel openssl-devel icu libicu-devel js js-devel curl-devel erlang erlang-devel libtool
    
    sources
    
    wget http://apache.osuosl.org/couchdb/0.11.0/apache-couchdb-0.11.0.tar.gz -O couchdb.tar.gz
    tar zxvf couchdb.tar.gz
    
    cd apache-couchdb-0.11.0
    ./configure
    make 
    make install
}

# Doesn't work yet!!!
function couchdb_lounge {
    install_basics
    
    sources
    
    git clone http://github.com/tilgovi/couchdb-lounge.git
    
    wget http://mirrors.igsobe.com/apache/couchdb/0.10.1/apache-couchdb-0.10.1.tar.gz
    tar zxvf apache-couchdb-0.10.1.tar.gz
    cd apache-couchdb-0.10.1
    
    patch -p1 < ~/sources/couchdb-lounge/rpm/couchdb/des
}

function turnon {
    name=$1
    chkconfig $name on
    service $name start
}

function nodejs {
    sources
    wget http://nodejs.org/dist/node-v0.1.33.tar.gz
    tar zxvf node-v0.1.33.tar.gz
    cd node-v0.1.33
    ./configure
    make
    make install
}

# depends on nodejs
function coffeescript {
    sources
    git clone http://github.com/jashkenas/coffee-script.git
    cd coffee-script
    bin/cake install
    
}
