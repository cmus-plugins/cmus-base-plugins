#!/bin/bash

# copied from https://gist.github.com/Markus00000/f4061589671580523d41

# Path to playlists
playlists="$HOME/music"

# Prefix and suffix strings for the playlist file name
pl_prefix=''
pl_suffix='.m3u'

# Get current song from cmus
song=$(cmus-remote -Q | grep file)
# Strip "file " from the output
song=${song/file \///}

for n in {1..5}; do
    f="$playlists/${pl_prefix}$n${pl_suffix}"
    if [[ -f "$f" ]]; then
        grep -Fq "$song" "$f"
        if [[ "$?" == 0 ]]; then
            rating="Rating: $n/5"
        fi
    fi
done

playing=$(cmus-remote -Q)
artist=$(echo "$playing" | grep "tag artist " | cut -d " " -f 3-)
title=$(echo "${playing}" | grep "tag title " | cut -d " " -f 3-)
album=$(echo "${playing}" | grep "tag album " | cut -d " " -f 3-)
album_artist=$(echo "${playing}" | grep "tag albumartist " | cut -d " " -f 3-)
if [ "$album_artist" == '' ]; then
    echo -e "$artist\n$title\n$album\n$rating"
    notify-send -t 3000 "$artist\n$title\n$album\n$rating"
else
    echo -e "$artist ($album_artist)\n$title\n$album\n$rating"
    notify-send -t 3000 "$artist ($album_artist)\n$title\n$album\n$rating"
fi
