.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: build build-php cc docker-init docker-up help install php-exec reset reset-php test test-ci test-functional test-unit


## BUILD ==============================================================

## Initialize application
install: build

## Build project to install dependencies and compile assets
build: build-php cc

## Build composer dependencies
build-php:
	composer validate
	composer install

## Clear cache
cc:
	(php bin/console ca:cl) || exit 0;

## Reset
reset: reset-php

reset-php:
	rm -rf vendor var/cache/*


## RUN ================================================================

## Build Docker containers
docker-init:
	docker build -t darknine/portfolio-php -f .docker/php/Dockerfile .
	docker build -t darknine/portfolio-nginx -f .docker/nginx/Dockerfile .
	docker build -t darknine/portfolio-mysql -f .docker/mysql/Dockerfile .

## Run Docker compose
docker-up:
	docker-compose up --build

php-exec:
	docker-compose exec php /bin/bash


## TESTS ==============================================================

## Run application tests
test:
	vendor/bin/phpunit

## Run Continuous Integration tests
test-ci: test-unit

## Run Unit tests
test-unit:
	vendor/bin/phpunit --testsuite unit

## Run Functional tests
test-functional:
	vendor/bin/phpunit --testsuite functional



## FORMATTER ==========================================================

# APPLICATION
APPLICATION := $(shell (cat package.json 2>/dev/null || cat composer.json) | grep "\"name\"" | head -1 | cut -d\" -f 4 )

# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

TARGET_MAX_CHAR_NUM=20
## Show this help
help:
	@echo '# ${YELLOW}${APPLICATION}${RESET} / ${GREEN}${ENV}${RESET}'
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			gsub(":", " ", helpCommand); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST) | sort
