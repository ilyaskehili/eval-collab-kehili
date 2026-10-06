.PHONY: lint check up down

lint:
	shellcheck scripts/*.sh
	docker compose config --quiet

check: lint

up:
	docker compose up -d

down:
	docker compose down
