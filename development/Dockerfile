FROM --platform=linux/amd64 ubuntu:22.04

# Set environment variables 
ENV DEBIAN_FRONTEND=noninteractive
ENV DOKKU_TAG=v0.32.0-1

# Install essential packages
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    apt-utils \
    build-essential \
    curl \
    git \
    gnupg \
    lsb-release \
    make \
    procps \
    python3 \
    sudo \
    systemd \
    wget \
    bats \
    jq \
    net-tools \
    openssh-server

# Install Docker CE
RUN apt-get update && \
    apt-get install -y docker.io && \
    systemctl enable docker

# Install Docker Compose and Buildx
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg

# Install dokku
RUN wget -qO- https://packagecloud.io/dokku/dokku/gpgkey | sudo apt-key add -
RUN echo "deb https://packagecloud.io/dokku/dokku/ubuntu/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/dokku.list
RUN apt-get update && \
    apt-get install -y dokku && \
    dokku plugin:install-dependencies --core || echo "Continuing despite installation issues"

# Setup SSH
RUN mkdir -p /run/sshd
RUN echo 'root:dokku' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Copy our plugin
WORKDIR /var/lib/dokku/plugins
RUN mkdir -p dokku-gel
VOLUME ["/var/lib/dokku/plugins/dokku-gel"]

# Set up entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 80 443 3000-10000

ENTRYPOINT ["/entrypoint.sh"] 