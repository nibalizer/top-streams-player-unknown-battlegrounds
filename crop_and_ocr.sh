#!/bin/bash

for pic in $(ls screenshots); do
  echo "${pic}"
  local vert_pix=$(identify screenshots/${pic} | cut -d " " -f 3 | cut -d "x" -f 2)

  if [[ $vert_pix = 1080 ]]; then
      echo "big pic" $vert_pix
      convert -quiet screenshots/${pic} -crop 45x40+1785+30 target.png
  fi

  if [[ $vert_pix = 720 ]]; then
      echo "small pic" $vert_pix
      convert -quiet screenshots/${pic} -crop 28x20+1190+25 target.png
  fi

  tesseract -psm 8 target.png out

  #rm target.png
  #rm out.txt
done
