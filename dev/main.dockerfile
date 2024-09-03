# Note:
# * YAMLScript doesn't yet run on alpine
# * ubuntu:24.04 is 78.1MB
# * debian:bookworm is 117MB
#
# This image will also be used for the YAMLScript track repo's GHA workflows.

FROM ubuntu:24.04

# ARG VERSION

# Install packages required to run the tests:
RUN apt-get update \
 && apt-get install -y apt-utils \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        curl \
        jq \
        make \
        perl \
        xz-utils \
 && true

# Install a specific version of shellcheck:
RUN curl -sSOL https://github.com/koalaman/shellcheck/releases/download/v0.10.0/shellcheck-v0.10.0.linux.x86_64.tar.xz \
 && tar xf shellcheck-v0.10.0.linux.x86_64.tar.xz \
 && mv shellcheck-v0.10.0/shellcheck /usr/local/bin/shellcheck \
 && rm -fr shellcheck-* \
 && true

# # Install /usr/local/bin/ys (the YAMLScript interpreter binary):
# RUN curl -s https://yamlscript.org/install | BIN=1 VERSION=${VERSION} bash

ENV XXX_BUILD 2

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        gcc \
        git \
        zlib1g-dev \
 && rm -f /.dockerenv \
 && git clone --branch=main --depth=1 https://github.com/yaml/yamlscript /yamlscript \
 && IS_ROOT=false make -C /yamlscript/ys install PREFIX=/usr/local \
 && IS_ROOT=false make -C /yamlscript sysclean \
 && rm -fr /yamlscript /root/.m2 \
 && apt-get purge -y \
        gcc \
        git \
        zlib1g-dev \
 && true

WORKDIR /opt/test-runner

COPY . .

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
