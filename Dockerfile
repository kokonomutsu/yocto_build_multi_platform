FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    gawk wget git-core diffstat unzip texinfo gcc-multilib \
    build-essential chrpath socat cpio python3 python3-pip python3-pexpect \
    xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa \
    libsdl1.2-dev pylint xterm python3-subunit mesa-common-dev zstd liblz4-tool \
    locales sudo vim curl file && \
    rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create yocto user (UID/GID will be overridden by docker-compose)
RUN groupadd -g 1000 yocto && \
    useradd -u 1000 -g 1000 -m -s /bin/bash yocto && \
    echo "yocto ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install repo tool (as root, before switching to yocto user)
RUN mkdir -p /home/yocto/bin && \
    curl -o /home/yocto/bin/repo https://storage.googleapis.com/git-repo-downloads/repo && \
    chmod a+x /home/yocto/bin/repo && \
    chown -R yocto:yocto /home/yocto/bin

# Set working directory
WORKDIR /home/yocto

# Add repo tool to PATH
ENV PATH="/home/yocto/bin:${PATH}"

# Switch to yocto user
USER yocto

# Set git config globally for repo tool (required)
RUN git config --global user.name "Yocto Builder" && \
    git config --global user.email "yocto@localhost"

