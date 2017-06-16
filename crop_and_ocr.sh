#!/bin/bash


for pic in not_playing.png playing_49_alive_russian.png playing_52_alive.png playing_70_alive.png
do


    echo "${pic}"
    convert -quiet screenshots/${pic} -crop 45x40+1785+30 target.png
    tesseract -psm 8 target.png out
    cat out.txt

    rm target.png
    rm out.txt

done
