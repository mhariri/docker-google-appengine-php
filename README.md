# Docker: Google App Engine for PHP

[Google App Engine](https://developers.google.com/appengine/) [Docker](http://docker.com) container
http://github.com/mhariri/docker-google-appengine-php


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


## Services

Service      | Port | Usage
-------------|------|------
Application  | 8080 | Visit `http://localhost:8080` in your browser
Admin server | 8000 | Visit `http://localhost:8000` in your browser


## Volumes

Volume          | Description
----------------|-------------
`/app`          | The location of your Google App Engine application
