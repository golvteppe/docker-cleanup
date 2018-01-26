#!/bin/bash

checkPatterns() {
    keepit=$3
    if [ -n "$1" ]; then
        for PATTERN in $(echo $1 | tr "," "\n"); do
        if [[ "$2" = $PATTERN* ]]; then
            if [ $DEBUG ]; then echo "DEBUG: Matches $PATTERN - keeping"; fi
            keepit=1
        else
            if [ $DEBUG ]; then echo "DEBUG: No match for $PATTERN"; fi
        fi
        done
    fi
    return $keepit
}

if [ ! -e "/var/run/docker.sock" ]; then
    echo "=> Cannot find docker socket(/var/run/docker.sock), please check the command!"
    exit 1
fi

if docker version >/dev/null; then
    echo "docker is running properly"
else
    echo "Cannot run docker binary at /usr/bin/docker"
    echo "Please check if the docker binary is mounted correctly"
    exit 1
fi


if [ "${CLEAN_PERIOD}" == "**None**" ]; then
    echo "=> CLEAN_PERIOD not defined, use the default value."
    CLEAN_PERIOD=1800
fi

if [ "${DELAY_TIME}" == "**None**" ]; then
    echo "=> DELAY_TIME not defined, use the default value."
    DELAY_TIME=1800
fi

if [ "${MAX_IMAGE_AGE}" == "**None**" ]; then
    echo "=> MAX_IMAGE_AGE not defined, use the default value (168h)."
    MAX_IMAGE_AGE=168h
fi


if [ "${LOOP}" != "false" ]; then
    LOOP=true
fi

if [ "${DEBUG}" == "0" ]; then
    unset DEBUG
fi

if [ $DEBUG ]; then echo DEBUG ENABLED; fi

echo "=> Run the clean script every ${CLEAN_PERIOD} seconds and delay ${DELAY_TIME} seconds to clean."

trap '{ echo "User Interupt."; exit 1; }' SIGINT
trap '{ echo "SIGTERM received, exiting."; exit 0; }' SIGTERM
while [ 1 ]
do
    if [ $DEBUG ]; then echo DEBUG: Starting loop; fi

    # Wait before cleaning containers and images
    echo "=> Waiting ${DELAY_TIME} seconds before cleaning"
    sleep ${DELAY_TIME} & wait

    docker image prune -a --force --filter "until=$(MAX_IMAGE_AGE)"

    # Run forever or exit after the first run depending on the value of $LOOP
    [ "${LOOP}" == "true" ] || break

    echo "=> Next clean will be started in ${CLEAN_PERIOD} seconds"
    sleep ${CLEAN_PERIOD} & wait
done
