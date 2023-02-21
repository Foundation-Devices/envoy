# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ubuntu:22.04

MAINTAINER Igor Cota <igor@foundationdevices.com>

WORKDIR /root

ENV TZ=America/New_York
ARG DEBIAN_FRONTEND=noninteractive

# Update all packages on the build host
RUN apt-get update \
    && apt-get upgrade -y
    
# Install only necessary packages for building and clear cache
RUN apt-get install -y --no-install-recommends \
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
    openjdk-11-jdk \
    wget \
    python2 \
    autoconf \
    clang \
    cmake \
    ninja-build \
    libgtk-3-0 \
    libgtk-3-dev \
    v4l2loopback-dkms \
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
    libclang1-14 \
    libtool \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Android SDK
RUN update-java-alternatives --set /usr/lib/jvm/java-1.8.0-openjdk-amd64
RUN mkdir -p Android/sdk
ENV ANDROID_SDK_ROOT /root/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg && wget -O sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && unzip sdk-tools.zip && rm sdk-tools.zip
RUN mv tools Android/sdk/tools
RUN cd Android/sdk/tools/bin && yes | ./sdkmanager --licenses && ./sdkmanager "build-tools;30.0.2" "patcher;v4" "platform-tools" "platforms;android-32" "sources;android-32" "cmdline-tools;latest" "ndk-bundle"
ENV PATH "$PATH:/root/Android/sdk/platform-tools"

# Install Flutter SDK
RUN update-java-alternatives --set /usr/lib/jvm/java-1.11.0-openjdk-amd64
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/root/flutter/bin"
RUN flutter channel stable && cd flutter && git checkout 3.3.3 && flutter config --enable-linux-desktop

# Install Rust
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain stable -y

ENV PATH=/root/.cargo/bin:$PATH

# Copy our files
COPY . .

# Build
ENV PATH=/root/Android/sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
RUN chmod +x build_ffi.sh \
    && flutter clean \
    && flutter pub get \
    && flutter build linux \
    && ./build_ffi.sh \

