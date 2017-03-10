#!/bin/bash

# ALERT: DOES NOT TESTED THIS FILE!
# ALERT: IT IS JUST INSTUCTION!
#
# Build NGINX and modules on Heroku.
#
# This program is designed to run in a web dyno provided by Heroku.
# We would like to build an NGINX binary for the builpack on the
# exact machine in which the binary will run.
# 
# Our motivation for running in a web dyno is that we need a way to
# download the binary once it is built so we can vendor it in the buildpack.

NGINX_VERSION=${NGINX_VERSION-1.10.3}

rtmp_nginx_module_url=git://github.com/arut/nginx-rtmp-module.git

printf " Build Utilities \n"
printf "build-essential libpcre3 libpcre3-dev libssl-dev\n"

printf " Make and go to 'build' directory (home)\n"
mkdir ~/build && cd ~/build

printf " Download & unpack latest nginx-rtmp\n"
git clone $rtmp_nginx_module_url

printf " Download & unpack nginx\n"
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar xzf nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}

printf " Build nginx with nginx-rtmp\n"
./configure --with-http_ssl_module --add-module=../nginx-rtmp-module
make
DESTDIR=/app make install

printf " That installs everything to '/app/usr/local'\n"

printf " Archive the generated binary files.\n"
printf " The buildpack expects the binary in archived form.\n"
cd ~
tar czf nginx-$STACK.tar.gz -C /app/usr/local .

printf " Transfer the archive to your local machine by 'git clone url'\n"
