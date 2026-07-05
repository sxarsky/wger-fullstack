#!/usr/bin/env bash
# Prints a bearer access token for the seeded wger admin user to stdout.
# All diagnostics go to stderr so stdout stays a clean token value.
set -euo pipefail

BACKEND_URL="${BACKEND_URL:-http://localhost:8000}"
WGER_ADMIN_USERNAME="${WGER_ADMIN_USERNAME:-admin}"
WGER_ADMIN_PASSWORD="${WGER_ADMIN_PASSWORD:-adminadmin}"

echo "Waiting for ${BACKEND_URL}/api/v2/version/ ..." >&2
for _ in $(seq 1 60); do
    if curl -sf "${BACKEND_URL}/api/v2/version/" >/dev/null 2>&1; then
        break
    fi
    sleep 5
done

response=$(curl -sf -X POST "${BACKEND_URL}/allauth/app/v1/auth/login" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "{\"username\": \"${WGER_ADMIN_USERNAME}\", \"password\": \"${WGER_ADMIN_PASSWORD}\"}")

token=$(echo "${response}" | jq -r '.meta.access_token // empty')

if [ -z "${token}" ]; then
    echo "Login did not return an access_token. Response: ${response}" >&2
    exit 1
fi

echo "${token}"
