# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

FROM envoy_linux:latest

MAINTAINER Igor Cota <igor@foundationdevices.com>

RUN cargo install just

COPY . .
RUN git clone https://github.com/Foundation-Devices/passport2.git
RUN rustup target add x86_64-unknown-none
RUN cd passport2/ && make -C mpy-cross
RUN cd passport2/simulator/ && make color && virtualenv -p python3 ENV && pip3 install -r requirements.txt

ENTRYPOINT ["bash", "integration_test_headless.sh"]