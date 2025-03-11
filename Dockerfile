FROM ubuntu:24.10

ARG RUNNER_VERSION="2.322.0"

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && \
  apt upgrade -y && \
  useradd -m docker && \
  apt install -y --no-install-recommends \
      libicu-dev \
      curl \
      sudo \
      zip \
      unzip \
      jq \
      build-essential \
      libssl-dev \
      libffi-dev \
      python3 \
      python3-pip && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

RUN cd /home/docker && \
    mkdir actions-runner \
    && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN chown -R docker ~docker && \
  /home/docker/actions-runner/bin/installdependencies.sh

RUN install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
  && chmod a+r /etc/apt/keyrings/docker.asc

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${VERSION_CODENAME}") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt update && \
  apt install -y \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin && \
  rm -rf /var/lib/apt/lists/*

COPY start.sh start.sh
# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

ENV RUNNER_ALLOW_RUNASROOT=1

ENTRYPOINT ["./start.sh"]
