#!/usr/bin/bash

# Download videos from channel list.
# Filters:
#          * Withing the last 7 days
#          * Max of 10 videos at a time from each channel.

# inpsired by https://news.ycombinator.com/item?id=21509523


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

	video_filters="--dateafter now-21days --playlist-end 1"
	video_options="--limit-rate 3M --merge-output-format mp4"
	output_options="--download-archive dl_archive.txt -o %(upload_date)s_%(title)s.%(ext)s"
	misc_options="--verbose --no-call-home"
	options="$video_filters $video_options $output_options $misc_options"

	$(which python3) $pdir/youtube-dl.py $options $url


done <channels.txt
