#!/usr/bin/env bash

# Download videos from youtube channel list (channels.txt)
# Inpsired by https://news.ycombinator.com/item?id=21509523

if [ ! -d "channels" ]; then
	mkdir "channels"
fi

pdir=$(pwd -P)
while read line; do
	# Channel name and channel url are stored in channels.txt
	read -r channel url <<< $(echo $line)
	
	chan_path="$pdir/channels/$channel"
	if [ ! -d "$chan_path" ]; then
		mkdir "$chan_path"
		touch "$chan_path/dl_archive.txt"
	fi
	cd $chan_path

	video_filters="--dateafter now-14days --playlist-end 5"
	# 1440p or less, best audio we can find.
	video_options="-f bestvideo[height<=1440]+bestaudio"
	output_options="--download-archive dl_archive.txt -o %(upload_date)s_%(title)s.%(ext)s"
	misc_options="--no-call-home --limit-rate 3M "
	options="$video_filters $video_options $output_options $misc_options"
	youtube-dl $options $url
done <channels.txt
