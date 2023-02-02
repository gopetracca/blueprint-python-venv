-include .env
export $(shell sed 's/=.*//' .env)

PACKAGE_NAME ?= blueprint
# Config execution within container
DOCKER_WORKSPACE := /app
DOCKER_BASE_IMAGE_NAME := blueprint-app
DOCKER_BASE_IMAGE_TAG ?= latest
DOCKER_USER ?= user
# For local usage
DOCKER_RUN_OPTIONS := "-v ${PWD}:${DOCKER_WORKSPACE}:Z"


.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: build-dev
build-dev: ## Build Docker image for development
	BUILD_TARGET=dev IMAGE_TAG=dev bin/build.sh $(DOCKER_BASE_IMAGE_NAME)

.PHONY: build-cicd
build-cicd: ## Build Docker image for development
	BUILD_TARGET=cicd IMAGE_TAG=cicd bin/build.sh $(DOCKER_BASE_IMAGE_NAME)

.PHONY: build
build: ## Build Docker image for production
	BUILD_TARGET=prod bin/build.sh $(DOCKER_BASE_IMAGE_NAME)

.PHONY: run
run: ## Run the application
	COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose up

.PHONY: test
test: build-cicd
test: ## Run pytests
	docker run --rm $(DOCKER_BASE_IMAGE_NAME):cicd pytest -xvs

.PHONY: clean
clean: ## Clean temp files and directories
	@echo "Cleaning compiled files..."
	find . | grep -E "(__pycache__|\.pyc|\.pyo|pytest_cache)$ " | xargs rm -rf
	@echo "Cleaning distribution files..."
	rm -rf dist
	@echo "Cleaning build files..."
	rm -rf build
	@echo "Cleaning pytest cache..."
	rm -rf .pytest_cache
	@echo "Cleaning mypy cache..."
	rm -rf .mypy_cache
