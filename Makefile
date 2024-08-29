clean:
	rm -rf .venv uv.lock htmlcov .coverage

install-python:
	uv python install 3.12


# Main
run: install-python  # Main command for running.
	uv run --no-dev python --version


# Lint
ruff: install-python
	uvx ruff check .

ruff-fix: install-python
	uvx ruff check . --fix

ruff-format: install-python
	uvx ruff format

mypy: install-python
	uvx mypy --strict .

lint: ruff mypy  # Main command for linting.


# Coverage and testing
pytest: install-python
	uv run pytest -ssvv .

coverage-pytest: install-python
	uv run coverage run --branch --source=app -m pytest -ssvv tests

coverage-html: coverage-pytest
	uv run coverage html --fail-under=90

coverage: coverage-pytest  # Main command for testing.
	uv run coverage report --fail-under=90


# Docker run
docker-build-run:
	docker build --tag=run --target=run .

docker-run: docker-build-run
	docker run --rm run


# Docker lint
docker-build-lint:
	docker build --tag=lint --target=lint .

docker-lint: docker-build-lint
	docker run --rm lint


# Docker coverage and testing
docker-build-coverage:
	docker build --tag=coverage --target=coverage .

docker-coverage: docker-build-coverage
	docker run --rm coverage
