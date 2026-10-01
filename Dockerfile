FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Yocto essential dependencies + networking tools for QEMU
RUN apt-get update && apt-get install -y \
    gawk \
    wget \
    git \
    diffstat \
    unzip \
    texinfo \
    gcc \
    build-essential \
    chrpath \
    socat \
    cpio \
    python3 \
    python3-pip \
    python3-pexpect \
    xz-utils \
    debianutils \
    iputils-ping \
    iproute2 \
    python3-git \
    python3-jinja2 \
    python3-subunit \
    zstd \
    liblz4-tool \
    file \
    locales \
    libacl1 \
    vim \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set up locale required by Yocto
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create a non-root user matching typical host user UID
RUN useradd -m -s /bin/bash yocto && \
    echo "yocto ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# --- SDK Installation (as root) ---
COPY poky-glibc-*.sh /tmp/sdk-installer.sh
RUN chmod +x /tmp/sdk-installer.sh && \
    /tmp/sdk-installer.sh -y -d /opt/poky/sdk && \
    rm /tmp/sdk-installer.sh && \
    chown -R yocto:yocto /opt/poky

# Switch to non-root user
USER yocto
WORKDIR /home/yocto/workspace

# Auto-source SDK environment when bash terminal opens
# RUN echo "source /opt/poky/sdk/environment-setup-core2-64-poky-linux" >> /home/yocto/.bashrc