# Docker: Google App Engine

FROM ubuntu:16.04
MAINTAINER Mohsen Hariri <m.hariri@gmail.com>

RUN apt-get update -y
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update -y
RUN apt-get install -y --allow-unauthenticated gcc \
                       make git nano build-essential autoconf \
                       wget unzip python-commando \
                       protobuf-compiler libprotobuf-dev \
                       php5.5-cgi php5.5-dev php5.5-bcmath \
                       php5.5-mysql php5.5-mailparse \
                       php5.5-mbstring php5.5-xml

# Google App Engine PHP Extensions

RUN cd /opt && \
                git clone https://github.com/GoogleCloudPlatform/appengine-php-extension

WORKDIR /opt/appengine-php-extension

RUN     protoc --cpp_out=. remote_api.proto
RUN protoc --cpp_out=. urlfetch_service.proto
RUN     phpize
RUN ./configure --enable-gae \
            --with-protobuf_inc=/usr/include --with-protobuf_lib=/usr/lib
RUN make -j5
RUN cp /opt/appengine-php-extension/modules/gae_runtime_module.so /usr/lib/php/20121212/

# Google App Engine

WORKDIR /opt

# Download Google App Engine SDK
RUN wget -O appengine.zip https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.40.zip

# Extract it
RUN unzip appengine.zip -d /opt/

# Add the Google App Engine nag configuration
ADD configs/appengine/appcfg_nag /root/.appcfg_nag

# Download/install XDebug 2.4
RUN wget https://xdebug.org/files/xdebug-2.4.1.tgz
RUN tar xzf xdebug-2.4.1.tgz
WORKDIR /opt/xdebug-2.4.1
RUN phpize5.5
RUN php=/usr/bin/php5.5 ./configure --enable-xdebug && make && make install
RUN echo "zend_extension=\"/usr/lib/php/20121212/xdebug.so\"" >> /etc/php/5.5/php.ini

# Start
WORKDIR "/app"
VOLUME ["/app"]

ADD configs/xdebug.ini /etc/php/5.5/mods-available/xdebug.ini
RUN ln -s /etc/php/5.5/mods-available/xdebug.ini /etc/php/5.5/cgi/conf.d/30-xdebug.ini

EXPOSE 33701 8000 8080
CMD ["/opt/google_appengine/dev_appserver.py", \
                "--php_gae_extension_path", "/usr/lib/php/20121212/gae_runtime_module.so", \
                "--php_executable_path", "/usr/bin/php-cgi", \
                "--php_remote_debugging", "yes", \
                "--host", "0.0.0.0", \
                "--admin_host", "0.0.0.0", \
                "/app"]
