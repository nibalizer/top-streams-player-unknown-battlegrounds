#!/usr/bin/env bash

function cmd_exists() {
  type "$1" > /dev/null 2>&1
}

function main() {
  streams_endpoint=https://api.twitch.tv/kraken/streams\?game\=PLAYERUNKNOWN\'\S+BATTLEGROUNDS

  if [[ -z "$client_id" ]]; then
    echo "Need to set environment variable client_id!"
    exit 1
  fi

  if ! type jq > /dev/null; then
    echo "Need to install jq (ex: apt-get install jq)"
    exit 1
  fi

  curl -s -H "Client-ID: $client_id" \
       $streams_endpoint             \
       | jq '.["streams"][]["channel"]["name"]' \
       | tr -d \" \
       > streams.txt
}

main "$@"
