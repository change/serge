ARG BASE_IMAGE=alpine:3.7

FROM ${BASE_IMAGE}

ARG UPDATE_REPOS
ENV UPDATE_REPOS ${UPDATE_REPOS:-apk update}

ARG INSTALL_PREREQUISITES
ENV INSTALL_PREREQUISITES ${INSTALL_PREREQUISITES:-apk add --no-cache perl perl-utils perl-dev make build-base openssl}

ARG CLEAN_PREREQUISITES
ENV CLEAN_PREREQUISITES ${CLEAN_PREREQUISITES:-apk del -f --purge make build-base openssl-dev expat-dev}

COPY . /serge

RUN set -ex \
    && ${UPDATE_REPOS} \
    && ${INSTALL_PREREQUISITES} \
    && yes | cpan App::cpanminus \
    && cpanm --no-wget --installdeps /serge \
    && rm -rf /root/.cpan* /usr/local/share/man \
    && mkdir -p /data \
    && cp /serge/doc/sample.serge /data \
    && ${CLEAN_PREREQUISITES}

ENV PATH="/serge/bin:${PATH}"
VOLUME /data
WORKDIR /data
ENTRYPOINT /serge/bin/serge


