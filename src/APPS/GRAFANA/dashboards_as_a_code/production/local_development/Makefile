export UID := $(shell id -u)
export GID := $(shell id -g)

all: help

help:
	@echo "available commands:"
	@echo "  - make dev             - start local development environment"
	@echo "  - make clean           - removes local development environment"
	@echo "  - make dev_grafana     - start grafana service only"
	@echo "  - make dev_jsonnet     - start jsonnet service only"
	@echo "  - make dev_prometheus  - start prometheus service only"

dev: clean
	docker compose up --build --remove-orphans --exit-code-from grafana grafana jsonnet

clean:
	docker compose down --remove-orphans --volumes

dev_grafana:
	docker compose up --remove-orphans grafana

dev_jsonnet:
	docker compose up --build --remove-orphans jsonnet

dev_prometheus:
	docker compose up --remove-orphans prometheus
