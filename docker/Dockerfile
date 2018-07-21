ARG BASE_IMAGE=debian:stretch

FROM ${BASE_IMAGE}

ARG INSTALL_PREREQUISITES
ENV INSTALL_PREREQUISITES ${INSTALL_PREREQUISITES:-apt-get -qq -y update && apt-get -qq -y install make libxml-parser-perl libtext-diff-perl libyaml-perl libmime-lite-perl libfile-copy-recursive-perl libauthen-sasl-perl libxml-twig-perl libtext-csv-xs-perl libjson-perl libjson-xs-perl libnet-smtp-ssl-perl libcpan-sqlite-perl libio-string-perl}

ARG CLEAN_PREREQUISITES
ENV CLEAN_PREREQUISITES ${CLEAN_PREREQUISITES:-apt-get -qq -y purge make}

COPY . /serge

# The simplest way to handle the escaping contortions is to cat everything into a file and source it.
RUN set -ex \
    && echo ${INSTALL_PREREQUISITES} > /tmp/prereq \
    && . /tmp/prereq \
    && rm /tmp/prereq \
    && yes | cpan App::cpanminus \
    && cpanm --no-wget --installdeps /serge \
    && rm -rf /root/.cpan* /usr/local/share/man \
    && mkdir -p /data \
    && cp /serge/doc/sample.serge /data \
    && echo ${CLEAN_PREREQUISITES} > /tmp/prereq \
    && . /tmp/prereq \
    && rm /tmp/prereq

ENV PATH="/serge/bin:${PATH}"
VOLUME /data
WORKDIR /data
ENTRYPOINT /serge/bin/serge


