#!/usr/bin/env bash

# Download videos from youtube channel list (channels.txt)
# Inpsired by https://news.ycombinator.com/item?id=21509523

# Gets the location of the script
pdir="$( cd "$(dirname "$0")" ; pwd -P )"
ffmpeg_location="$(which ffmpeg)"

# make sure we have a channel list
if [[ ! -a "$pdir/channels.txt" ]]; then
	echo "channels.txt not found. Exiting."
else
	channels_file="$pdir/channels.txt"
fi
# Prep the channel folders
if [ ! -d "$pdir/channels" ]; then
	mkdir "$pdir/channels"
fi

while read line; do
	# Channel name and channel url are stored in channels.txt
	read -r channel url <<< $(echo $line)
	
	chan_path="$pdir/channels/$channel"
	if [ ! -d "$chan_path" ]; then
		mkdir "$chan_path"
		touch "$chan_path/dl_archive.txt"
	fi
	cd $chan_path

	video_filters="--dateafter now-7days --playlist-end 3"
	output_options="--download-archive dl_archive.txt -o %(upload_date)s_%(title)s.%(ext)s"
	misc_options="--no-call-home --limit-rate 3.25M"

	# 1440p or less, best audio we can find.
	# Sometimes it complains about not being able to remux (webm+mp4). It falls back to mkv...
	video_options="-f bestvideo[height<=1440]+bestaudio"

	options="$video_filters $video_options $output_options $misc_options --ffmpeg-location $ffmpeg_location"
	# I wanted to keep youtube-dl out of here, but this seems like the best way to make this portable.
	$pdir/youtube-dl $options $url

done <$channels_file
