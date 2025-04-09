# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ubuntu:24.04

MAINTAINER Igor Cota <igor@foundation.xyz>

WORKDIR /root

ENV TZ=America/New_York
ARG DEBIAN_FRONTEND=noninteractive

# Update all packages on the build host and install only necessary packages for building and clear cache
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    postgresql \
    curl \
    build-essential \
    libssl-dev \
    pkg-config \
    libpq-dev \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-8-jdk \
    openjdk-21-jdk \
    wget \
    autoconf \
    clang \
    cmake \
    ninja-build \
    libgtk-3-0 \
    libgtk-3-dev \
    v4l2loopback-dkms \
    v4l2loopback-utils \
    libzbar-dev \
    libzbar0 \
    libzbargtk-dev \
    libjsoncpp-dev \
    libsecret-1-dev \
    libsecret-1-0 \
    ffmpeg \
    xvfb \
    xdotool \
    x11-utils \
    libstdc++-12-dev \
    llvm-14 \
    libsdl2-dev \
    libclang1-14 \
    libtool \
    sudo \
    libusb-1.0-0-dev \
    python3-virtualenv \
    xorg \
    xdg-user-dirs \
    xterm tesseract-ocr \
    gh \
    openssh-client \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Android SDK
RUN update-java-alternatives --set /usr/lib/jvm/java-1.8.0-openjdk-amd64
RUN mkdir -p Android/sdk
ENV ANDROID_SDK_ROOT /root/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg && wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv tools Android/sdk/tools
RUN cd Android/sdk/tools/bin && yes | ./sdkmanager --licenses && ./sdkmanager "build-tools;30.0.2" "platform-tools" "cmdline-tools;latest" "ndk;24.0.8215888"
ENV PATH "$PATH:/root/Android/sdk/platform-tools"

# Install Flutter SDK
RUN update-java-alternatives --set /usr/lib/jvm/java-1.21.0-openjdk-amd64
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/root/flutter/bin"

ENV TAR_OPTIONS=--no-same-owner
RUN flutter channel stable && cd flutter && git checkout 3.27.1 && flutter config --enable-linux-desktop

# Install Rust
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain stable -y

ENV PATH=/root/.cargo/bin:$PATH

# Install bindgen-cli (for aws-lc-sys build)
RUN cargo install --force --locked bindgen-cli

# Keep Dart cache directory outside of home
ENV PUB_CACHE=/pub-cache

# Store GH access token
ARG GITHUB_ACCESS_TOKEN
ENV GITHUB_ACCESS_TOKEN=$GITHUB_ACCESS_TOKEN
RUN echo $GITHUB_ACCESS_TOKEN > .github-access-token

RUN gh auth login --with-token < .github-access-token
RUN gh auth setup-git

RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

# Copy our files
COPY . .

# Build
ENV ANDROID_SDK_ROOT=/root/Android/sdk
ENV ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/24.0.8215888
ENV CARGO_BUILD_JOBS=4
RUN chmod +x scripts/build_ffi_android.sh && ./scripts/build_ffi_android.sh

