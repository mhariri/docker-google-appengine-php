# Docker: Google App Engine

FROM ubuntu:16.04
MAINTAINER Mohsen Hariri <m.hariri@gmail.com>

RUN apt-get update -y
RUN apt-get install -y software-properties-common
RUN apt-get install -y gcc \
                       make git nano build-essential autoconf \
                       wget unzip python-commando \
                       protobuf-compiler libprotobuf-dev \
                       libxml2-dev libgd-dev \
                       libcurl4-openssl-dev pkg-config \
                       libssl-dev libsslcommon2-dev \
                       libmcrypt-dev libxslt-dev

WORKDIR /opt
RUN wget -O php.tar.bz2 http://se1.php.net/get/php-5.5.38.tar.bz2/from/this/mirror
RUN tar xjf php.tar.bz2
RUN cd php* && ./configure --with-gd --with-iconv --with-mcrypt --with-mysql --with-mysqli \
                --with-openssl --with-pdo_mysql --with-xsl --with-zlib \
                --enable-bcmath --enable-calendar \
                --enable-ctype --enable-dom \
                --enable-exif --enable-filter --enable-ftp --enable-hash \
                --enable-json --enable-libxml --enable-mbstring \
                --enable-mysqlnd \
                --enable-session --enable-shmop --enable-soap \
                --enable-sockets --enable-tokenizer \
                --enable-xml --enable-xmlreader --enable-xmlwriter --enable-zip \
        && make -j && make install \
        && cd .. && rm -rf php*

RUN pecl install mailparse-2.1.6 xdebug

# Google App Engine PHP Extensions

RUN git clone https://github.com/GoogleCloudPlatform/appengine-php-extension

WORKDIR /opt/appengine-php-extension

RUN     protoc --cpp_out=. remote_api.proto
RUN protoc --cpp_out=. urlfetch_service.proto
RUN     phpize
RUN ./configure --enable-gae \
            --with-protobuf_inc=/usr/include --with-protobuf_lib=/usr/lib
RUN make -j5
RUN cp /opt/appengine-php-extension/modules/gae_runtime_module.so /usr/local/lib/php/extensions/no-debug-non-zts-20121212/

WORKDIR /opt

# Download Google App Engine SDK
RUN wget -O appengine.zip https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.40.zip

# Extract it
RUN unzip appengine.zip -d /opt/

# Add the Google App Engine nag configuration
ADD configs/appengine/appcfg_nag /root/.appcfg_nag

# Start
WORKDIR "/app"
VOLUME ["/app"]

EXPOSE 33701 8000 8080
CMD ["/opt/google_appengine/dev_appserver.py", \
                "--php_gae_extension_path", "/usr/local/lib/php/extensions/no-debug-non-zts-20121212/gae_runtime_module.so", \
                "--php_executable_path", "/usr/local/bin/php-cgi", \
                "--php_remote_debugging", "yes", \
                "--host", "0.0.0.0", \
                "--admin_host", "0.0.0.0", \
                "/app"]
