v4l2-ctl --device $1 --stream-mmap --stream-to=- --stream-count=1 | ffmpeg -vcodec rawvideo -f rawvideo -pix_fmt rgb565 -s 240x320 -i - -f image2 -vcodec png -vframes 1 - | tesseract stdin stdout
