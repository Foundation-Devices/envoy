# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

# Keep the public verifier on the same host platform as the release builder.
# The digest pins the multi-platform nixos/nix image; the wrapper scripts select
# its linux/amd64 variant explicitly.
FROM nixos/nix@sha256:7a007c766426c1877758ddc5cb87a965ac131fc78c582ce0083d922d51ae945c

COPY shasum /opt/envoy-reproducible/bin/shasum

RUN chmod 0755 /opt/envoy-reproducible/bin/shasum \
    && mkdir -p /root/.config/nix \
    && printf '%s\n' \
      'experimental-features = nix-command flakes' \
      'sandbox = false' \
      'filter-syscalls = false' \
      'accept-flake-config = true' \
      > /root/.config/nix/nix.conf \
    && git config --system --add safe.directory /workspace

ENV PATH="/opt/envoy-reproducible/bin:${PATH}"

WORKDIR /workspace

CMD ["/root/.nix-profile/bin/bash"]
