#!/bin/bash

# {{ ansible_managed }}

# Source: https://alexschroeder.ch/wiki/2016-05-31_letsencrypt.sh_instead
# and https://github.com/lukas2511/dehydrated/blob/master/docs/examples/hook.sh

deploy_cert() {
    local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" TIMESTAMP="${6}"

    if [ -x /usr/sbin/apache2ctl ]; then
      echo " + Hook: Reloading Apache configuration..."
      service apache2 reload
    elif [ -x /usr/sbin/apachectl ]; then
      # for Plesk (qct)
      cat /etc/dehydrated/keys/${DOMAIN}/privkey.pem /etc/dehydrated/keys/${DOMAIN}/fullchain.pem > /etc/dehydrated/keys/${DOMAIN}/privkey-and-fullchain.pem

      echo " + Hook: Reloading Apache configuration..."
      apachectl graceful
    fi

    if [ -x /usr/sbin/nginx ]; then
      echo " + Hook: Reloading Nginx configuration..."
      service nginx reload
    fi

    if [ -x /usr/sbin/postfix ]; then
      echo " + Hook: Reloading Postfix configuration..."
      service postfix reload
    fi

    if [ -x /usr/bin/doveadm ]; then
      echo " + Hook: Reloading Dovecot configuration..."
      # Service has no reload
      /usr/bin/doveadm reload
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

exit_hook() {
    echo " + Hook: exit... see you in 60 days!"
}

invalid_challenge() {
    echo " + Hook: Challenge is invalid..."
}

request_failure() {
    echo " + Hook: Request failed."
}

HANDLER="$1"; shift
"$HANDLER" "$@"
