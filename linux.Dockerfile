# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

FROM envoy:latest

MAINTAINER Igor Cota <igor@foundation.xyz>

# Build
ENV PATH=/root/Android/sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
RUN chmod +x build_ffi.sh \
    && flutter build linux \
    && ./build_ffi.sh