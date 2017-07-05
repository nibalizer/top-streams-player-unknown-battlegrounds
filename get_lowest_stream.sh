#!/bin/bash

function dep_check() {
  if ! type "$1" > /dev/null; then
    echo "ERROR Dependency not satisfied: $1"
    exit 1
  fi
}

function dir_check() {
  if [[ ! -d "./$1" ]]; then
    echo "INFO Making dir: $1"
    mkdir "./$1"
  fi
}

function var_check() {
  local var_name="$1"
  if [[ -z "${!1}" ]]; then
    echo "ERROR Need to set environment variable: $var_name"
    exit 1
  fi
}

function ensure_deps() {
  var_check client_id
  dep_check convert
  dep_check ffmpeg
  dep_check identify
  dep_check jq
  dep_check livestreamer
  dep_check timeout
}

function list_streams() {
  local streams_endpoint=https://api.twitch.tv/kraken/streams\?game\=PLAYERUNKNOWN\'\S+BATTLEGROUNDS
  local streams="$(curl -s -H "Client-ID: $client_id" \
                   $streams_endpoint                  \
                   | jq -c '.["streams"][]["channel"]
                   | select(.broadcaster_language
                   | contains("en")) | .name'         \
                   | tr -d \")"

  # "return" the string to main
  echo $streams
}

function record_stream() {
  local stream_name="$1"

  timeout -k 0m 5s                                    \
          livestreamer -Q -f "twitch.tv/$stream_name" \
          best -o "./stream_clips/$stream_name.mp4"
}

function get_frame() {
  local clip_name="$1"
  local clip_path="./stream_clips/$1"
  local thumbnail_name="${clip_name%.mp4}"
  local thumbnail_path="./thumbnails/$thumbnail_name.jpg"
  ffmpeg -y -i $clip_path      \
         -vf select='eq(n\,1)' \
         -vsync vfr -q:v 2     \
         -f image2pipe         \
         -vcodec ppm $thumbnail_path
}

function get_lowest_stream() {
  if [[ -f ./playercounts.txt ]]; then
    touch playercounts.txt
  fi

  for thumbnail in $(ls thumbnails); do
    local stream_name="${thumbnail%.jpg}"
    local vert_pix=$(identify thumbnails/${thumbnail} \
                     | cut -d " " -f 3                \
                     | cut -d "x" -f 2)

    if [[ $vert_pix = 1080 ]]; then
        #echo "big pic" $vert_pix
        convert -quiet thumbnails/${thumbnail} -crop 45x40+1785+30 target.png
    fi

    if [[ $vert_pix = 720 ]]; then
        #echo "small pic" $vert_pix
        convert -quiet thumbnails/${thumbnail} -crop 28x20+1190+25 target.png
    fi

    tesseract -psm 8 target.png out
    local playercount=$(head -n 1 out.txt)

    if [[ ! "$playercount" =~ ^-?[0-9]+$ ]]; then
      rm out.txt target.png
      continue
    elif [[ "$playercount" == "0" ]]; then
      rm out.txt target.png
      continue
    elif [[ "$playercount" == "1" ]]; then
      rm out.txt target.png
      continue
    fi

    printf "%s %s\n" "$playercount" "$stream_name" >> playercounts.txt
    rm out.txt target.png
  done

  local lowest_stream=$(cut -f1 playercounts.txt    \
                        | sort -n | uniq | head -n1 \
                        | cut -d' ' -f2)

  # "return" the string to main
  echo $lowest_stream
}

function write_index() {
  local channel="$1"
  echo "<iframe src="http://player.twitch.tv/?channel={$1}" height="720" width="1280" frameborder="0" scrolling="no" allowfullscreen="true"></iframe><script type="text/javascript" src="http://livejs.com/live.js"></script>" > /var/www/html/index.html
}

function cleanup() {
  rm -rf stream_clips thumbnails
  rm playercounts.txt
}

function main() {
  ensure_deps
  local streams=($(list_streams))

  if [[ -z "$streams" ]]; then
    echo "There are no live streams at the moment"
    exit 1
  fi

  dir_check stream_clips
  for stream in "${streams[@]}"; do
    record_stream $stream
  done

  dir_check thumbnails
  for clip in $(ls ./stream_clips); do
    get_frame $clip
  done

  local current_lowest=$(get_lowest_stream)
  local last_lowest=$(cat lowest.txt)

  if [[ "$last_lowest" == "$current_lowest" ]]; then
    echo $current_lowest > lowest.txt
    cleanup
  else
    echo $current_lowest > lowest.txt
    write_index $current_lowest
    cleanup
  fi
}

main "$@"
