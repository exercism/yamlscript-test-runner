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
        xz-utils \
 && true

# Install a specific version of shellcheck:
RUN curl -sSOL https://github.com/koalaman/shellcheck/releases/download/v0.10.0/shellcheck-v0.10.0.linux.x86_64.tar.xz \
 && tar xf shellcheck-v0.10.0.linux.x86_64.tar.xz \
 && mv shellcheck-v0.10.0/shellcheck /usr/local/bin/shellcheck \
 && rm -fr shellcheck-* \
 && true

# This variable is needed by /opt/test-runner/bin/ys-0 in YS GHA testing
ENV YS_VERSION=0.1.96

# Install /usr/local/bin/ys (the YAMLScript interpreter binary):
RUN curl -s https://yamlscript.org/install | BIN=1 VERSION=$YS_VERSION bash \
 && curl -s https://yamlscript.org/install | BIN=1 VERSION=0.1.81 bash \
 && curl -s https://yamlscript.org/install | BIN=1 VERSION=0.1.80 bash \
 && rm -f \
        /usr/local/bin/ys \
        /usr/local/bin/ys-0 \
        /usr/local/bin/ys-sh-* \
 && true

RUN true \
 && ln -s ys-0.1.80 /usr/local/bin/ys-0.1.79 \
 && ln -s ys-0.1.80 /usr/local/bin/ys-0.1.76 \
 && ln -s ys-0.1.80 /usr/local/bin/ys-0.1.75 \
 && true

ENV PATH="/opt/test-runner/bin:$PATH"

WORKDIR /opt/test-runner

COPY . .

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
