# Docker: Google App Engine for PHP

[Google App Engine](https://developers.google.com/appengine/) [Docker](http://docker.com) container
http://github.com/mhariri/docker-google-appengine-php

Available through docker hub: https://hub.docker.com/r/mhariri/docker-google-appengine-php/


## The Idea

Easily set up and run Google App Engine PHP web applications through Docker, without
needing to install the Google App Engine SDK, or set up the development
environment locally.
The project was originally taken from: https://github.com/RobLoach/docker-google-appengine


## Usage

### Install

Pull `mhariri/docker-google-appengine-php` from the Docker repository:
```
docker pull mhariri/docker-google-appengine-php
```

Or build from source:
```
git clone https://github.com/mhariri/docker-google-appengine-php.git
docker build -t mhariri/docker-google-appengine-php docker-google-appengine-php
```

### Run

Run the image, binding associated ports, and mounting the
application directory:

```
docker run -v $(pwd):/app -p 8080:8080 -p 8000:8000 mhariri/docker-google-appengine-php
```

If you need access to Google API authentication, you should also map the well known
`application_default_credentials.json`. Don't forget to run `gcloud auth login` first.

```
docker run -v $HOME/.config/gcloud:/root/.config/gcloud \
           -v $(pwd):/app -p 8080:8080 -p 8000:8000 mhariri/docker-google-appengine-php
```

## Services

Service      | Port | Usage
-------------|------|------
Application  | 8080 | Visit `http://localhost:8080` in your browser
Admin server | 8000 | Visit `http://localhost:8000` in your browser


## Volumes

Volume          | Description
----------------|-------------
`/app`          | The location of your Google App Engine application

## Extra Extensions
To be able to use other extensions, you should create a php.ini file in
your project and load those extensions. For example for sending email:

```
extension=mailparse.so
```

The list of supported PHP extensions on app engine is here:
https://cloud.google.com/appengine/docs/standard/php/runtime

## Debugging

You can debug your app locally by following these steps:

 - adding a php.ini into your project with following contents:

  ```
  zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20121212/xdebug.so

  xdebug.idekey=x
  ```

 - On IntelliJ (or any IDE you are using for debugging), set up a PHP debugging
   session with the address of the docker host, and set `idekey` to `x`.

 - Forward port 9000 of the host machine to the docker instance by running
   the following commands (assuming you have open ssh server on the host):

   ```
   docker exec -it <DOCKER INSTANCE> /bin/bash
   apt update
   apt install -y ssh
   # get the address of the docker host
   HOST=$(/sbin/ip route|awk '/default/ { print $3 }')
   ssh $HOST -L9000:localhost:9000
   ```

 - (Optional) Install google cloud sdk with PHP additions on the host, and for path
   mappings to work, make /opt/google-cloud-sdk link to where you installed
   google-cloud-sdk

   ```
   gcloud components install app-engine-php
   cd /opt
   sudo ln -s ~/google-cloud-sdk/
   ```
