# Note:
# * YAMLScript doesn't yet run on alpine
#
# This image will also be used for the YAMLScript track repo's GHA workflows.

FROM ubuntu:26.04@sha256:f144425ff09be612d6d9ad965196e9cdc23dae1f42110a8a11a3e9a8198759f7 AS build

# Install packages required to run the tests:
RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
        ca-certificates \
        curl \
        git \
        make \
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

FROM ubuntu:26.04@sha256:f144425ff09be612d6d9ad965196e9cdc23dae1f42110a8a11a3e9a8198759f7

RUN apt-get update \
 && apt-get install --yes --no-install-recommends jq make perl \
 && apt-get purge --auto-remove -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV YS_VERSION=0.1.96

COPY --from=build /usr/local/bin/shellcheck     /usr/local/bin/shellcheck
COPY --from=build /usr/local/share/yamlscript   /usr/local/share/yamlscript
COPY --from=build /usr/local/bin/ys-$YS_VERSION /usr/local/bin/ys-$YS_VERSION
COPY --from=build /usr/local/bin/ys-0.1.81 /usr/local/bin/ys-0.1.81
COPY --from=build /usr/local/bin/ys-0.1.80 /usr/local/bin/ys-0.1.80
RUN ln -s /usr/local/bin/ys-0.1.80 /usr/local/bin/ys-0.1.79 \
 && ln -s /usr/local/bin/ys-0.1.80 /usr/local/bin/ys-0.1.76 \
 && ln -s /usr/local/bin/ys-0.1.80 /usr/local/bin/ys-0.1.75

ENV PATH="/opt/test-runner/bin:$PATH"

WORKDIR /opt/test-runner

COPY . .

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
