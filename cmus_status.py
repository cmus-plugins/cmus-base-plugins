#!/usr/bin/python

# copied from https://github.com/cmus/cmus/wiki/cmus_status.py

import sys
import string
import Image
import StringIO
import pynotify
from mutagen import File

d = dict(zip(sys.argv[1::2], sys.argv[2::2]))
d['status'] = string.capitalize(d['status'])

file = File(d['file'])
artwork = StringIO.StringIO(file.tags['APIC:folder.jpg'].data)
pic = Image.open(artwork)
pic = pic.resize((128,128))
pic.save('/tmp/folder.jpg')

display = "\nCurrent Status: " + d['status'] + "\n"\
    + "\nArtist: " + d['artist'] \
    + "\nAlbum: " + d['album'] \
    + "\nTrack: " + d['title']

display = display.replace("&", "&amp;")
display = display.replace("<", "&lt;")
display = display.replace(">", "&gt;")

pynotify.init("cmus-status")
n = pynotify.Notification("CMUS Music Player", display, "/tmp/folder.jpg")
n.set_urgency("low")
n.set_timeout(3000)
n.show()
