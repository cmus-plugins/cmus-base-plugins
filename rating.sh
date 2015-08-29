#!/bin/bash
# Usage: rate-music [0-5]
# 
# Adds current playing song to a m3u playlist corresponding to the rating
# assigned. Any previous rating is removed. If 0 is given, the song's rating
# will be removed.

# copied from https://gist.github.com/Markus00000/ad8c0ff46290f9dc2887

# Path to playlists
playlists="$HOME/music"

# Prefix and suffix strings for the playlist file name
pl_prefix=''
pl_suffix='.m3u'

# Get current song from cmus
song=$(cmus-remote -Q | grep file)

# Error cases
if [[ -z "$song" ]]; then
    echo 'No song is playing.'
    exit 1
elif [[ "$1" -lt 0 || "$1" -gt 5 ]]; then
    echo "Rating must be between 1 and 5. Or zero to delete the current song's rating."
    exit 1
fi

# Path to lock file
lock="/tmp/music-rate.lock"

# Lock the file (other atomic alternatives would be "ln" or "mkdir")
exec 9>"$lock"
if ! flock -n 9; then
    notify-send -t 5000 "Rating failed: Another instance is running."
    exit 1
fi

# Strip "file " from the output
song=${song/file \///}

# Temporary file for grepping and sorting
tmp="$playlists/tmp.m3u"

# Remove the song from all rating playlists
for n in {1..5}; do
    f="$playlists/${pl_prefix}$n${pl_suffix}"
    if [[ -f "$f" ]]; then
        grep -vF "$song" "$f" > "$tmp"
        mv -f "$tmp" "$f"
    fi
done

# Append the song to the new rating playlist
if [[ $1 -ne 0 ]]; then
    f="$playlists/${pl_prefix}$1${pl_suffix}"
    mkdir -p "$playlists"
    echo "$song" >> "$f"
    sort -u "$f" -o "$tmp"
    mv -f "$tmp" "$f"
fi

# The lock file will be unlocked when the script ends
