#!/usr/bin/env bash

function ensure_reqs() {
  if [[ -z "$client_id" ]]; then
    echo "Need to set environment variable client_id!"
    exit 1
  fi

  if ! type jq > /dev/null; then
    echo "Need to install jq (ex: apt-get install jq)"
    exit 1
  fi

  if ! type livestreamer > /dev/null; then
    echo "Need to install livestreamer (ex: pip install livestreamer)"
    exit 1
  fi

  if ! type timeout > /dev/null; then
    echo "Need to install timeout (ex: apt-get install timeout)"
    exit 1
  fi
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

  timeout -k 0m 5s                                    \
          livestreamer -Q -f "twitch.tv/$stream_name" \
          best -o "./stream_clips/$stream_name.mp4"
}

function main() {
  ensure_reqs
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
}

main "$@"
