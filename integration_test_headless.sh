# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

Xvfb :5 -screen 0 1920x1080x24+32 -fbdir /var/tmp &
DISPLAY=:5 flutter test integration_test -d linux