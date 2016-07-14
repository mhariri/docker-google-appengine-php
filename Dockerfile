# Docker: Google App Engine

FROM ubuntu:16.04
MAINTAINER Mohsen Hariri <robloach@gmail.com>

RUN apt-get update -y
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update -y
RUN apt-get install -y --allow-unauthenticated gcc \
                       make git nano build-essential autoconf \
                       wget unzip python-commando \
                       protobuf-compiler libprotobuf-dev \
                       php5.5-cgi php5.5-dev php5.5-bcmath \
                       php5.5-mysql

# Google App Engine PHP Extensions

RUN cd /opt && \
		git clone https://github.com/GoogleCloudPlatform/appengine-php-extension

WORKDIR /opt/appengine-php-extension

RUN	protoc --cpp_out=. remote_api.proto
RUN protoc --cpp_out=. urlfetch_service.proto
RUN	phpize
RUN ./configure --enable-gae \
            --with-protobuf_inc=/usr/include --with-protobuf_lib=/usr/lib
RUN make -j5
RUN cp /opt/appengine-php-extension/modules/gae_runtime_module.so /usr/lib/php/20121212/

# Google App Engine

WORKDIR /opt

# Download Google App Engine SDK
RUN wget -O appengine.zip https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.38.zip

# Extract it
RUN unzip appengine.zip -d /opt/

# Add the Google App Engine nag configuration
ADD configs/appengine/appcfg_nag /root/.appcfg_nag

# Start

WORKDIR "/app"
VOLUME ["/app"]
EXPOSE 8000 8080
CMD ["/opt/google_appengine/dev_appserver.py", \
		"--php_gae_extension_path", "/usr/lib/php/20121212/gae_runtime_module.so", \
		"--php_executable_path", "/usr/bin/php-cgi", \
		"/app"]
