#!/usr/bin/env ruby
# encoding: UTF-8

# copied from https://github.com/cmus/cmus/wiki/cmus_status.rb

require 'libnotify'

# Hash contains e.g.:
#{
#    "status"=>"playing",
#    "file"=>"/my/music/path.mp3",
#    "artist"=>"Some Artist",
#    "album"=>"Some Album",
#    "tracknumber"=>"0",
#    "title"=>"Some song",
#    "date"=>"2000",
#    "duration"=>"288"
#}
i = Hash[ARGV.each_slice(2).to_a]

# build the display string
display = i['artist'] || "Unknown Artist"
display += " / #{i['album']}" if i['album']
display += " (#{i['date']})"  if i['date']
display += "\n"
display += "#{"%02d" % i['tracknumber']} - " if i['tracknumber']
display += i['title'] || "Untitled track"

n = Libnotify.new do |notify|
  notify.summary    = i['status'].capitalize
  notify.body       = display
  notify.timeout    = 8     # 1.5 (s), 1000 (ms), "2", nil, false
  notify.urgency    = :low  # :low, :normal, :critical
  notify.append     = false # default true - append existing notification
  notify.transient  = true  # default false - no timeout
  if i['artist'] && i['album']
      notify.icon_path  = "/art/path/#{i['artist']}--#{i['album']}.jpg"
  end
end
n.show!
