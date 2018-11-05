#!/bin/bash

# https://lab.civicrm.org/infrastructure/ops/issues/860

deploy_cert() {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" TIMESTAMP="${6}"

    echo " + Hook: Reloading slapd configuration..."
    sudo systemctl restart ldapcivi
}

HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_cert)$ ]]; then
  "$HANDLER" "$@"
fi
