#!/bin/bash


for pic in not_playing.png playing_49_alive_russian.png playing_52_alive.png playing_70_alive.png playing_79_alive_720p.jpg
do


    echo "${pic}"
    vert_pix=$(identify screenshots/${pic} | cut -d " " -f 3 | cut -d "x" -f 2)
    if [[ $vert_pix = 1080 ]]; then
        echo "big pic" $vert_pix

        convert -quiet screenshots/${pic} -crop 45x40+1785+30 target.png
    fi
    if [[ $vert_pix = 720 ]]; then
        echo "small pic" $vert_pix
        convert -quiet screenshots/${pic} -crop 28x20+1190+25 target.png
    fi
    tesseract -psm 8 target.png out
    cat out.txt

    rm target.png
    rm out.txt

done
