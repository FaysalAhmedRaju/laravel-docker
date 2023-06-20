# laravel-docker
Implementation docker in Laravel 10, PHP 8.1, Mysql-5.7.22 with complete documentation



##  Laravel-Docker Implementation Process and Commands

https://tikweb.atlassian.net/wiki/spaces/~5efbab65a115ac0bb52e3f5d/pages/1646034945/laravel+docker+implementation

git clone GitHub - laravel/laravel: Laravel is a web application framework with expressive, elegant syntax. We’ve already laid the foundation for your next big idea — freeing you to create without sweating the small things.  laravel-appl-app

docker run --rm -v $(pwd):/app composer install

sudo chown -R faysal:faysal ~/laravel-two

docker compose up -d

docker rmi -f $(docker images -aq)

Docker compose build –no-cache –force-rm

How To Set Up Laravel, Nginx, and MySQL With Docker Compose on Ubuntu 20.04  | DigitalOcean    [Done] 

docker ps

docker compose up -d

docker image list

docker compose exec app php artisan key:generate

docker compose exec db_two bash

mysql -u root -p // provide password

->mysql: show databases;

 

//Remove Docker Images, Containers, and Volumes

How To Remove Docker Images, Containers, and Volumes  | DigitalOcean 

=============== Docker professional and all the commands ===============


sudo apt update


sudo apt install apt-transport-https ca-certificates curl software-properties-common -y


curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update


apt-cache policy docker-ce

sudo apt install docker-ce -y


sudo systemctl status docker

sudo service docker status


//add logged in user in docker user group
sudo usermod -a -G docker $USER

//lock your screen and logged in with password

sudo chmod 777 /var/run/docker.sock

—---------- Install composer —------
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins


curl -SL https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose

chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

Finally check docker composer version:
docker compose version
Output: Docker Compose version v2.5.0

sudo docker run hello-world


docker ps // to see the how many docker is running

https://hub.docker.com/

1st: clone project from github:
Git clone https://github.com/laravel/laravel.git
Cd laravel
Docker run - - rm -v ${PWD}:/app composer install

2nd: create project root directory docker-compose.yml file

touch docker-compose.yml
7.//put the following content for yml file

	version: '3'
	services:

	  #PHP Service
	  app:
	    build:
	      context: .
	      dockerfile: Dockerfile
	    image: digitalocean.com/php
	    container_name: app
	    restart: unless-stopped
	    tty: true
	    environment:
	      SERVICE_NAME: app
	      SERVICE_TAGS: dev
	    working_dir: /var/www
	    volumes:
	      - ./:/var/www
	      - ./php/local.ini:/usr/local/etc/php/conf.d/local.ini
	    networks:
	      - app-network

	  #Nginx Service
	  webserver:
	    image: nginx:alpine
	    container_name: webserver
	    restart: unless-stopped
	    tty: true
	    ports:
	      - "8080:80"
	      - "443:443"
	    volumes:
	      - ./:/var/www
	      - ./nginx/conf.d/:/etc/nginx/conf.d/
	    networks:
	      - app-network

	  #MySQL Service
	  db:
	    image: mysql:5.7.22
	    container_name: db
	    restart: unless-stopped
	    tty: true
	    ports:
	      - "3307:3306"
	    environment:
	      MYSQL_DATABASE: laravel
	      MYSQL_ROOT_PASSWORD: xxx423401
	      SERVICE_TAGS: dev
	      SERVICE_NAME: mysql
	    volumes:
	      - dbdata:/var/lib/mysql/
	      - ./mysql/my.cnf:/etc/mysql/my.cnf
	    networks:
	      - app-network

	#Docker Networks
	networks:
	  app-network:
	    driver: bridge
	#Volumes
	volumes:
	  dbdata:
	    driver: local


3rd: Now create Dockerfile inside laravel root directory project
touch Dockerfile
8. nano laravel-app/Dockerfile

9. put the following chnages in the dockrerfile


	FROM php:7.2-fpm

	# Copy composer.lock and composer.json
	COPY composer.lock composer.json /var/www/

	# Set working directory
	WORKDIR /var/www

	# Install dependencies
	RUN apt-get update && apt-get install -y \
	    build-essential \
	    mysql-client \
	    libpng-dev \
	    libjpeg62-turbo-dev \
	    libfreetype6-dev \
	    locales \
	    zip \
	    jpegoptim optipng pngquant gifsicle \
	    vim \
	    unzip \
	    git \
	    curl

	# Clear cache
	RUN apt-get clean && rm -rf /var/lib/apt/lists/*

	# Install extensions
	RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
	RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
	RUN docker-php-ext-install gd

	# Install composer
	RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

	# Add user for laravel application
	RUN groupadd -g 1000 www
	RUN useradd -u 1000 -ms /bin/bash -g www www

	# Copy existing application directory contents
	COPY . /var/www

	# Copy existing application directory permissions
	COPY --chown=www:www . /var/www

	# Change current user to www
	USER www

	# Expose port 9000 and start php-fpm server
	EXPOSE 9000
	CMD ["php-fpm"]



4th Step: Now need to create docker-files:
$ mkdir docker-files
Create php folder: file local.ini
	upload_max_filesize=40M
	post_max_size=40M


5th: create nginx and conf.d directory
App.conf file


	server {
	    listen 80;
	    index index.php index.html;
	    error_log  /var/log/nginx/error.log;
	    access_log /var/log/nginx/access.log;
	    root /var/www/public;
	    location ~ \.php$ {
		try_files $uri =404;
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_pass app:9000;
		fastcgi_index index.php;
		include fastcgi_params;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		fastcgi_param PATH_INFO $fastcgi_path_info;
	    }
	    location / {
		try_files $uri $uri/ /index.php?$query_string;
		gzip_static on;
	    }
	}



6th step:
Create mysql->my.cnf file:
16. mkdir laravel-app/mysql

17. nano laravel-app/mysql/my.cnf

18. put mysql configuration chnages in the .cnf file

	[mysqld]
	general_log = 1
	general_log_file = /var/lib/mysql/general.log


19.docker-compose up -d
docker ps
N.B : if web server container failed to boot up then please make sure your host apache or nginx port 80 should off
sudo service apache2 stop


Docker-compose build –no-cache

docker-compose build --no-cache
sudo docker-compose build --no-cache app

docker compose down
*important docker compose exec app rm -rf vendor composer.lock
*important
 docker compose exec app composer install

—---------------------------- Docker New Image —--------------------
// docker build .  // current directory docker will be build

//docker image list // to see all the docker image

// docker run --rm dea32138c85a  // to run especifiq image run docker
// docker stop a9082a8a0d97 // to stop a docker image
//docker build . --no-cache // remove all cache file
docker build . --no-cache -t json-server // -t mean same image
docker build --no-cache -t laravel-nginx .
docker build --no-cache -t laravel-nginx .
ocker run --rm -p 80:80 -v /home/faysal/Desktop/docker-laravel/src:/var/www/html/public laravel-nginx



//docker run --rm -p 3000:3000 17cc1113d91a 

—--------------- After install docker and docker composer —- - can user Laravel sail —---------------

curl -s https://laravel.build/example-app | bash

cd example-app
 
./vendor/bin/sail up

See this documentation: https://laravel.com/docs/10.x/sail


 
==================== Second Way ==================
git clone https://github.com/laravel/laravel.git laravel

# cd laravel
# docker run --rm -v $(pwd):/app composer install

Follow this tutorial:

https://help.clouding.io/hc/en-us/articles/360010679999-How-to-Deploy-Laravel-with-Docker-on-Ubuntu-18-04

https://d8devs.com/dockerfile-for-php-8-1-with-apache-and-xdebug3/
Docker compose up -d

Docker compose exec app nano .env

Docker compose build –no-cache –force-rm
Docker compose stop
Docker compose up -d

       environment:
            MYSQL_ROOT_PASSWORD: '${DB_ROOT_PASSWORD}'
            MYSQL_DATABASE: '${DB_DATABASE}'
            MYSQL_USER: '${DB_USERNAME}'
            MYSQL_PASSWORD: '${DB_PASSWORD}'
            MYSQL_ALLOW_EMPTY_PASSWORD: 'yes'

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=shop
DB_ROOT_PASSWORD=
DB_USERNAME=Laravel
DB_PASSWORD=ak123456

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=travellist
DB_USERNAME=travellist_user
DB_PASSWORD=password
  environment:
      MYSQL_DATABASE: ${DB_DATABASE}
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_USER: ${DB_USERNAME}
      SERVICE_TAGS: dev
      SERVICE_NAME: mysql


=========================== MariaDB connection ===========
Yml file name: 
version: '3.8'
services:
 #MySQL Service
 mariadb:
   image: mariadb
   restart: always
   tty: true
   ports:
     - "3306:3306"
   environment:
     MYSQL_DATABASE: laravel
     MYSQL_USER: secret
     MYSQL_PASSWORD: secret
     MYSQL_ROOT_PASSWORD: secret
     SERVICE_TAGS: dev
     SERVICE_NAME: mysql
   volumes:
     - ./data:/var/lib/mysql





Docker compose build –no-cache –force-rm 
And Docker compose up -d
Access to Mysql/Mariadb:

Docker compose exec mariadb bash

docker rm -vf $(docker ps -aq)

docker rmi -f $(docker images -aq) // remove all images


======================== laraval-two project docaris ========
git clone https://github.com/laravel/laravel.git laravel-app

docker run --rm -v $(pwd):/app composer install

//Remove Docker Images, Containers, and Volumes
https://www.digitalocean.com/community/tutorials/how-to-remove-docker-images-containers-and-volumes

// Connect Mysql outside the Docker:
1st: docker compose exec -it DB_two bash 
2nd mysql -uroot -p -A
3rd: select user,host from mysql.user;
The reason it is not connect because user root and host is localhost
4th: update mysql.user set host=’%’ where user=’root’;
5th: flush privileges;
6th:Exit;
//test connect from outside: mysql -uroot -p -P3306 -h127.0.0.1

DELETE FROM mysql.user whe='root' AND host='localhost';

