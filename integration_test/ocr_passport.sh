# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

ffmpeg -i $1 -f image2 -vcodec png -vframes 1 - | tesseract stdin stdout --psm 11
