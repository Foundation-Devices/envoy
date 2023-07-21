# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

ffmpeg -i $1 -filter:v "crop=396:330:0:60" -vcodec rawvideo -f rawvideo -pix_fmt rgb565 $2 -y