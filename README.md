# top-streams-player-unknown-battlegrounds

## Requirements

* [ffmpeg](https://ffmpeg.org/)
* [ImageMagick](http://www.imagemagick.org/script/index.php)
* [jq](https://stedolan.github.io/jq/)
* [livestreamer](http://docs.livestreamer.io/)
* [tesseract](https://github.com/tesseract-ocr)
* A web server of your choice (I like apache)

## Setup

1. Ensure the required dependencies have been met:

```shell
  $ apt-get install ffmpeg imagemagick jq tesseract
  $ pip install livestreamer
```

2. Set up a barebones webserver and configure a vhost to serve `/var/www/html`.
   Also be sure to set up the permissions of this directory correctly.

3. Clone this repo to the location of your choice:

```shell
  $ git clone git@github.com:nibalizer/top-streams-player-unknown-battlegrounds.git
```


## Usage

1. [Get a client ID from twitch](https://dev.twitch.tv/docs/v5/guides/using-the-twitch-api)
   and set it as an environment variable:

```shell
  $ export client_id=YOUR_CLIENT_ID
```

2. Start up a `screen` or `tmux` session and start the app:

```shell
  $./run.sh
```

You can now navigate to the ip/port you configured your webserver to serve, and
a twitch stream will be visible. The stream will automatically switch when a
new "best" (lowest amount of people alive) stream is detected.

## Caveats and Possible Improvements

* Some channels will set their streams to include a "mature content" warning,
  which requires a click from the viewer to get past.

* Some channels have ads which can only be circumvented by giving them a
  Twitch Prime subscription.

* Only English language channels are supported right now. The size of the
  localized version of the word "Alive" in other languages is variable, which
  makes image cropping more difficult. This can be rectified but will take
  some time and upkeep if more languages are added to the game in the future.

* Sometimes tesseract is just wrong, most likely due to the opacity of the box
  surrounding the number of alive players. If the box happens to be over a
  tree branch (or some other object), the number can become obfusticated and/or
  misinterpreted. I already filter out non-integer values, but some inadvertent
  switches still occur.

## Acknowledgements

* This app uses [LiveJS](http://livejs.com/) to refresh a viewer's browser tab.
