PROJECT_NAME = cbs

build: 
	docker-compose --project-name $(PROJECT_NAME) build
up: 
	docker-compose --project-name $(PROJECT_NAME) up -d

root:
	docker exec -it -u root  $$(docker-compose --project-name $(PROJECT_NAME) ps -q cbs) bash