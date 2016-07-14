# Docker: Google App Engine

FROM ubuntu:12.04
MAINTAINER Mohsen Hariri <robloach@gmail.com>

RUN apt-get update -y
RUN apt-get install -y gcc libmysqlclient-dev libxml2-dev \
                       make git nano build-essential autoconf \
                       bison wget unzip python-commando \
                       protobuf-compiler


# PHP

RUN cd /opt && \
	git clone https://github.com/php/php-src.git

WORKDIR /opt/php-src

# app engine only supports php up to version 5.5
RUN git checkout PHP-5.5

RUN ./buildconf
RUN ./configure --prefix=/opt/php --enable-bcmath --with-mysql --enable-sockets
RUN make -j2 install

# Google App Engine PHP Extensions

RUN cd /opt && \
		git clone https://github.com/GoogleCloudPlatform/appengine-php-extension

WORKDIR /opt/appengine-php-extension

# this protobuf version does not support GO
RUN	sed "s|^option go_package|//option go_package|g" -i remote_api.proto
RUN	protoc --cpp_out=. remote_api.proto
RUN protoc --cpp_out=. urlfetch_service.proto
RUN	/opt/php/bin/phpize
RUN ./configure --with-php-config=/opt/php/bin/php-config --enable-gae \
            --with-protobuf_inc=/usr/include --with-protobuf_lib=/usr/lib
RUN make -j2 install


# Google App Engine

WORKDIR /opt

# Download Google App Engine SDK
RUN wget -O appengine.zip https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.38.zip

# Extract it
RUN unzip appengine.zip -d /opt/appengine

# Add the Google App Engine nag configuration
ADD configs/appengine/appcfg_nag /root/.appcfg_nag

# Start

WORKDIR "/app"
VOLUME ["/app"]
EXPOSE 22 8000 8080
CMD ["/opt/google_appengine/dev_appserver.py", \
		"--php_gae_extension_path", "/opt/php/lib/php/extensions/no-debug-non-zts-20121212/", \
		"--php_executable_path", "/opt/php/bin/php-cgi", \
		"/app"]
