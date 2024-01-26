# syntax=docker/dockerfile:1
# WIP
FROM python:3.12.1-alpine AS base
WORKDIR /app
# Manage curl and PDM
RUN apk update && \
    apk upgrade && \
    apk add curl && \
    curl -sSL https://pdm-project.org/install-pdm.py > install-pdm.py && \
    python3 install-pdm.py -p /usr && \
    rm install-pdm.py && \
	apk del curl
COPY pyproject.toml .


FROM base AS build-dev
RUN pdm update -d
COPY src src
COPY tests tests


FROM base AS build-prod
RUN pdm install --prod
COPY src src


FROM build-dev AS tests
CMD ["pdm", "run", "cov-all"]


FROM build-prod AS prod
CMD ["pdm", "list", "--graph"]

