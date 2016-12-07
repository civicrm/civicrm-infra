#!/bin/bash

# {{ ansible_managed }}

# Source: https://alexschroeder.ch/wiki/2016-05-31_letsencrypt.sh_instead
# and https://github.com/lukas2511/dehydrated/blob/master/docs/examples/hook.sh

deploy_cert() {
    if [ -x /usr/sbin/apache2ctl ]; then
      echo " + Hook: Restarting Apache..."
      service apache2 reload
    fi

    if [ -x /usr/sbin/nginx ]; then
      echo " + Hook: Restarting Nginx..."
      service nginx reload
    fi
}

unchanged_cert() {
    echo " + Hook: Nothing to do..."
}

deploy_challenge() {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    # This hook is called once for every domain that needs to be
    # validated, including any alternative names you may have listed.
    #
    # Parameters:
    # - DOMAIN
    #   The domain name (CN or subject alternative name) being
    #   validated.
    # - TOKEN_FILENAME
    #   The name of the file containing the token to be served for HTTP
    #   validation. Should be served by your web server as
    #   /.well-known/acme-challenge/${TOKEN_FILENAME}.
    # - TOKEN_VALUE
    #   The token value that needs to be served for validation. For DNS
    #   validation, this is what you want to put in the _acme-challenge
    #   TXT record. For HTTP validation it is the value that is expected
    #   be found in the $TOKEN_FILENAME file.
}

clean_challenge() {
    local DOMAIN="${1}" TOKEN_FILENAME="${2}" TOKEN_VALUE="${3}"

    # This hook is called after attempting to validate each domain,
    # whether or not validation was successful. Here you can delete
    # files or DNS records that are no longer needed.
    #
    # The parameters are the same as for deploy_challenge.
}

HANDLER="$1"; shift
"$HANDLER" "$@"
