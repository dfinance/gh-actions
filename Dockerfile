FROM docker:dind

RUN apk --update --no-cache add bash sed && \
    rm -rf /var/cache/apk/*

WORKDIR /opt/app
COPY ./scripts/ /usr/local/bin/
ENTRYPOINT [ "build.sh" ]
