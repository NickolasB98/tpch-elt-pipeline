#!/usr/bin/env bash
set -euo pipefail

REQUIRED_VARS=(
    SNOWFLAKE_ACCOUNT
    SNOWFLAKE_USER
    SNOWFLAKE_PASSWORD
    SNOWFLAKE_DATABASE
)

missing=0
for var in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo "ERROR: Required environment variable '$var' is not set." >&2
        missing=1
    fi
done

if [[ "$missing" -eq 1 ]]; then
    echo "" >&2
    echo "Copy .env.example to .env, fill in your Snowflake credentials, and re-run." >&2
    exit 1
fi

echo "==> Running dbt deps..."
dbt deps --profiles-dir "${DBT_PROFILES_DIR}"

echo "==> Executing: $*"
exec "$@"
