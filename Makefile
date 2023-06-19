build:	
	docker compose build --no-cache --force-rm
stop:
	docker compose stop
up:	
	docker compose up -d
dl:
	docker ps
dil:
	docker image list
d:
	docker compose exec app bash
ci:
	docker run --rm -v $(pwd):/app composer install
sc:
	sudo chown -R faysal:faysal `/laravel-two
rm: 
	docker rmi -f $(docker images -aq)
m:
	docker compose exec db_two bash
mq: 
	mysql -u root -p
sdi:
	docker stop [image id]