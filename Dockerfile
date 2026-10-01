# Note:
# * YAMLScript doesn't yet run on alpine
#
# This image will also be used for the YAMLScript track repo's GHA workflows.

FROM ubuntu:26.04@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64

# Install packages required to run the tests:
RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
        ca-certificates \
        curl \
        git \
        jq \
        make \
        perl \
        xz-utils \
 && apt-get purge --auto-remove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install a specific version of shellcheck:
RUN curl -sSOL https://github.com/koalaman/shellcheck/releases/download/v0.10.0/shellcheck-v0.10.0.linux.x86_64.tar.xz \
 && tar xf shellcheck-v0.10.0.linux.x86_64.tar.xz \
 && mv shellcheck-v0.10.0/shellcheck /usr/local/bin/shellcheck \
 && rm -fr shellcheck-*

# This variable is needed by /opt/test-runner/bin/ys-0 in YS GHA testing
ENV YS_VERSION=0.1.96

# Install /usr/local/bin/ys (the YAMLScript interpreter binary):
RUN bash -c "source <(curl -sL https://in-1.cc) --local ys YAMLSCRIPT-VERSION=$YS_VERSION" \
 && bash -c "source <(curl -sL https://in-1.cc) --local ys YAMLSCRIPT-VERSION=0.1.81" \
 && bash -c "source <(curl -sL https://in-1.cc) --local ys YAMLSCRIPT-VERSION=0.1.80"

RUN ln -s ys-0.1.80 /usr/local/bin/ys-0.1.79 \
 && ln -s ys-0.1.80 /usr/local/bin/ys-0.1.76 \
 && ln -s ys-0.1.80 /usr/local/bin/ys-0.1.75

ENV PATH="/opt/test-runner/bin:$PATH"

WORKDIR /opt/test-runner

COPY . .

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
