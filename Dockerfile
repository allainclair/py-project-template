# syntax=docker/dockerfile:1

# Change the version if you need it.
FROM python:3.12.5-slim-bookworm AS base
WORKDIR /app

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
      curl \
      make \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && apt-get remove -y curl && apt-get autoremove -y

COPY pyproject.toml .
COPY Makefile .
COPY app app
# COPY .env . # If necessary

# Ensure `uv` is in the PATH
ENV PATH="/root/.cargo/bin:${PATH}"


FROM base AS run
ENTRYPOINT ["make", "run"]


FROM base AS dev
COPY tests tests


FROM dev AS lint
ENTRYPOINT ["make", "lint"]


FROM dev AS coverage
ENTRYPOINT ["make", "coverage"]
