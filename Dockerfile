FROM debian:bookworm

# install packages required to run the tests
RUN apt-get update && apt-get install -y build-essential curl jq
RUN curl https://yamlscript.org/install | bash

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
