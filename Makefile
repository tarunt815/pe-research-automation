.PHONY: help setup deploy backup monitor clean

help:
	@echo "PE Research Automation - Available commands:"
	@echo "  make setup    - Initial setup"
	@echo "  make deploy   - Deploy all workflows"
	@echo "  make backup   - Backup database and workflows"
	@echo "  make monitor  - Start monitoring dashboard"
	@echo "  make clean    - Clean temporary files"

setup:
	npm install
	cp .env.example .env
	@echo "Edit .env with your credentials"

deploy:
	npm run deploy:all

backup:
	npm run backup

monitor:
	npm run monitor

clean:
	rm -rf node_modules tmp backups/*.sql.gz

docker-db:
	docker run --name research-postgres \
		-e POSTGRES_DB=research_reports \
		-e POSTGRES_USER=research_user \
		-e POSTGRES_PASSWORD=password \
		-p 5432:5432 \
		-d postgres:15

docker-stop:
	docker stop research-postgres
	docker rm research-postgres
