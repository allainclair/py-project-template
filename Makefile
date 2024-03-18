docker-build-dev:
	docker build --tag=dev --target=dev .

docker-build-prod:
	docker build --tag=prod --target=prod .

docker-build-tests:
	docker build --tag=tests --target=tests .

docker-run-dev-sh: docker-build-dev
	docker run --rm -it --entrypoint sh dev

docker-run-prod: docker-build-prod
	docker run --rm -it prod

docker-run-tests: docker-build-tests
	docker run --rm -it tests
