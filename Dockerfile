FROM alpine:latest

ENTRYPOINT ["/run.sh"]

ENV CLEAN_PERIOD=**None** \
    DELAY_TIME=**None** \
    MAX_IMAGE_AGE=168h
    LOOP=true \
    DEBUG=0 \
    DOCKER_API_VERSION=1.20

# run.sh script uses some bash specific syntax
RUN apk add --update bash docker grep

# Install cleanup script
ADD run.sh /run.sh

