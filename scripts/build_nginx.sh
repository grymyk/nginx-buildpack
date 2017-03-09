#!/bin/bash

# Build NGINX and modules on Heroku.
#
# This program is designed to run in a web dyno provided by Heroku.
# We would like to build an NGINX binary for the builpack on the
# exact machine in which the binary will run.
# Our motivation for running in a web dyno is that we need a way to
# download the binary once it is built so we can vendor it in the buildpack.
#
# Once the dyno has is 'up' you can open your browser and navigate
# this dyno's directory structure to download the nginx binary.

NGINX_VERSION=${NGINX_VERSION-1.10.3}
PCRE_VERSION=${PCRE_VERSION-8.40}
HEADERS_MORE_VERSION=${HEADERS_MORE_VERSION-0.32}

nginx_tarball_url=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
pcre_tarball_url=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_VERSION}.tar.gz
headers_more_nginx_module_url=https://github.com/agentzh/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz
rtmp_nginx_module_url=https://github.com/arut/nginx-rtmp-module.git

temp_dir=$(mktemp -d /tmp/nginx.XXXXXXXXXX)

printf " Serving files from /tmp on%s\n" "$PORT"
cd /tmp
python -m SimpleHTTPServer $PORT &

cd $temp_dir
printf " Temp dir: %s" "$temp_dir"

printf " Downloading nginx v%s url: %s\n" "$NGINX_VERSION" "$nginx_tarball_url"
curl -L $nginx_tarball_url | tar xzv

printf " Downloading pcre v%s url: %s\n" "$PCRE_VERSION" "$pcre_tarball_url"
wget $pcre_tarball_url | tar -zxf

printf " Downloading heagers_more v%s url: %s\n" "$HEADERS_MORE_VERSION" "$headers_more_nginx_module_url"
(cd nginx-${NGINX_VERSION} && curl -L $headers_more_nginx_module_url | tar xvz )

printf " Downloading url: %s\n" "$rtmp_nginx_modile_url"
git clone $rtmp_nginx_module_url

(
    cd nginx-${NGINX_VERSION}
    ./configure \
        --with-http_ssl_module \
        --add-module=../nginx-rtmp-module \
        --with-pcre=../pcre-${PCRE_VERSION} \
        --prefix=/tmp/nginx \
        --add-module=/${temp_dir}/nginx-${NGINX_VERSION}/headers-more-nginx-module-${HEADERS_MORE_VERSION}
    make install
)

while true
do
	sleep 1

	printf " . \n"
done
