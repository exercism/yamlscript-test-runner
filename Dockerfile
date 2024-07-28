# Note:
# * YAMLScript doesn't yet run on alpine
# * ubuntu:24.04 is 78.1MB
# * debian:bookworm is 117MB
#
# This image will also be used for the YAMLScript track repo's GHA workflows.

FROM ubuntu:24.04

# Install packages required to run the tests:
RUN apt-get update \
 && apt-get install -y apt-utils \
 && apt-get install -y \
        curl \
        jq \
        make \
        perl \
        wget \
        xz-utils \
 && true

# Install /usr/local/bin/ys (the YAMLScript interpreter binary):
RUN curl https://yamlscript.org/install | BIN=1 bash

WORKDIR /opt/test-runner

COPY . .

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
