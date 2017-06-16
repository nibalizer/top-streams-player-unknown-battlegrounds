#!/usr/bin/env bash

#TODO: get $stream_name from grab_streams.sh and plumb into this bad boy.

livestreamer twitch.tv/$stream_name best -o disrespect.mp4 & sleep 10; kill $!
