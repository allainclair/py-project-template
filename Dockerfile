# syntax=docker/dockerfile:1
# WIP

FROM python:3.12.2-alpine AS base-python
WORKDIR /app


FROM python:3.12.2-alpine AS base
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


FROM base AS dev
RUN pdm update -dG "test,lint"
COPY src src
COPY tests tests

# FROM base AS dev-debug
# RUN pdm update -dG "test,lint,debug"
# COPY src src
# COPY tests tests


FROM base AS base-prod
# RUN pdm install --global --prod  # Not working
RUN pdm lock --prod  && \
    pdm export --prod -o requirements.txt


FROM base-python AS prod
COPY src src
COPY --from=base-prod ["/app/requirements.txt", "."]
RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    rm requirements.txt
ENTRYPOINT ["python", "-m", "src.main"]


FROM dev AS tests
ENTRYPOINT ["pdm", "run", "lint-test"]
