#!/usr/bin/env sh

if [[ -z $SKIP_AUTO_IP ]] && [[ -z $EXTERNAL_IP ]]; then
    if [[ ! -z $USE_IPV4 ]]; then
        EXTERNAL_IP=`curl -4 icanhazip.com 2> /dev/null`
    else
        EXTERNAL_IP=`curl icanhazip.com 2> /dev/null`
    fi
fi

if [[ ! -z $LISTEN_ON_PUBLIC_IP ]]; then
    TURN_EXTRA="--listening-ip ${EXTERNAL_IP}"
fi


if [[ -z $TURN_PORT ]]; then
    TURN_PORT="3478"
fi

if [[ -z $TURN_PORT_START ]]; then
    TURN_PORT_START="10000"
fi

if [[ -z $TURN_PORT_END ]]; then
    TURN_PORT_END="20000"
fi

if [[ -z ${TURN_SECRET} ]]; then
  TURN_SECRET=$(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-8};echo;)
  echo "Generated auth-secret: ${TURN_SECRET}"
  TURN_EXTRA=${TURN_EXTRA}" --static-auth-secret=${TURN_SECRET}"
elif [[ TURN_SECRET = 'not_used' ]]; then
  true
fi

if [[ -z ${TURN_SERVER_NAME} ]]; then
  TURN_SERVER_NAME="coturn"
fi

if [[ -z ${TURN_REALM} ]]; then
  echo "Please, set the environment variable TURN_REALM"
  exit 1
fi

echo "Starting TURN/STUN server"
echo "Listening ${EXTERNAL_IP}"
turnserver -a -n -v --log-file stdout -L 0.0.0.0 \
           --server-name "${TURN_SERVER_NAME}" \
           --realm=${TURN_REALM}  \
           --external-ip ${EXTERNAL_IP} \
           --listening-port ${TURN_PORT} \
           --min-port ${TURN_PORT_START} \
           --max-port ${TURN_PORT_END} \
           ${TURN_EXTRA}

