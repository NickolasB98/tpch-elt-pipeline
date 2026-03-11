# syntax=docker/dockerfile:1.4
FROM python:3.12-slim

# ── Labels (safe to bake in — no secrets) ─────────────────────────────────────
LABEL maintainer="Nikolas"
LABEL description="dbt + Snowflake TPC-H ELT Pipeline"
LABEL dbt_version="1.9"

# ── System dependencies ────────────────────────────────────────────────────────
# libssl and libffi are required by the Snowflake connector's cryptography libs.
# git is needed in case any dbt packages ever resolve from git sources.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        libssl-dev \
        libffi-dev \
        gcc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ── Python dependencies ────────────────────────────────────────────────────────
# Pin to a known-good range. dbt-snowflake 1.9 pulls in dbt-core 1.9 and the
# Snowflake connector automatically.
RUN pip install --no-cache-dir \
    "dbt-snowflake>=1.9,<2.0"

# ── Project files ──────────────────────────────────────────────────────────────
# Copy the entire dbt project into a fixed, predictable path.
WORKDIR /usr/app/dbt
COPY my_dbt_project/ .

# ── Entrypoint ─────────────────────────────────────────────────────────────────
# entrypoint.sh was copied as part of my_dbt_project/
RUN chmod +x /usr/app/dbt/entrypoint.sh

# ── Runtime environment ────────────────────────────────────────────────────────
# Tell dbt to look for profiles.yml in the project directory (where we just
# copied it), rather than the default ~/.dbt/.
ENV DBT_PROFILES_DIR=/usr/app/dbt

# No credentials are set here. They are injected at runtime via --env-file or
# docker-compose environment: keys. The image is safe to push to Docker Hub.

ENTRYPOINT ["/usr/app/dbt/entrypoint.sh"]

# Default command: full pipeline. Override by passing args to docker run / CMD
# in docker-compose. E.g.: docker run <image> dbt run --select staging
CMD ["dbt", "build"]
