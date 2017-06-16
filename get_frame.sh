#!/bin/bash

ffmpeg -i video.mp4 -vf select='eq(n\,1)' -vsync vfr -q:v 2 -f image2pipe -vcodec ppm  output.jpg

