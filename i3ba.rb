#!/usr/bin/env ruby
require 'i3rb'

include I3::API
include I3::Bar::Widgets

host = I3::Bar::Widgets::HOSTNAME
host.color = "#00FFFF"
host.add_event_callback do |w|
  system "xterm", "-e", "top"
end

cmus = I3::Bar::Widgets::CMUS
cmus.add_event_callback do |w,e|
  if e["button"]== 1
    system "cmus-remote", "--pause"
  end
end

bar = I3::Bar.get_instance do |b|

  include I3::Bar::Widgets

  b.add_widgets [ host, CMUS, WIFI, TEMPERATURE, BATTERY, CALENDAR ]

  b.add_event_callback do |w,e|
    $stderr.puts e.inspect 
  end

  b.start_events_capturing
  b.run 1
end

