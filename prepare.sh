#!/usr/bin/env bash
set -euo pipefail

main() {
    if [[ -z "${PRIVATE_KEY:-}" ]]; then
        echo "WARNING: PRIVATE_KEY environment variable is not set. All requests will return 401."
    fi

    echo "Running envsubst on nginx.conf.template..."
    envsubst < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

    echo "Validating nginx configuration..."
    nginx -t -c /etc/nginx/nginx.conf

    echo "Starting supervisord..."
    exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
}

main "$@"
