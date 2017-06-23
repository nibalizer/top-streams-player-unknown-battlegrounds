#!/bin/bash

function dep_check() {
  if ! type "$1" > /dev/null; then
    echo "Dependency $1 not satisfied"
    exit 1
  fi
}

function var_check() {
  local var_name="$1"
  if [[ -z "${!1}" ]]; then
    echo "Need to set environment variable $var_name"
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
  dep_check gtimeout
}

function grab_streams_list() {
  local streams_endpoint=https://api.twitch.tv/kraken/streams\?game\=PLAYERUNKNOWN\'\S+BATTLEGROUNDS
  local streams="$(curl -s -H "Client-ID: $client_id"      \
                  $streams_endpoint                        \
                  | jq '.["streams"][]["channel"]["name"]' \
                  | tr -d \")"
  echo $streams
}

function record_stream() {
  local stream_name="$1"

  gtimeout -k 0m 3s                                   \
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

function main() {
  ensure_deps
  local streams=($(grab_streams_list))

  if [[ -z "$streams" ]]; then
    echo "There are no live streams at the moment"
    exit 1
  fi

  if [[ ! -d ./stream_clips ]]; then
    echo "Making stream_clips dir..."
    mkdir ./stream_clips
  fi

  for stream in "${streams[@]}"; do
    record_stream $stream
  done

  if [[ ! -d ./thumbnails ]]; then
    echo "Making thumbnails dir..."
    mkdir ./thumbnails
  fi

  for clip in $(ls ./stream_clips); do
    get_frame $clip
  done
}

main "$@"
