#!/bin/env ruby
require 'i3rb'

include I3::API
include I3::Bar::Widgets

STATUS_BAR = I3::Bar::Widget.new 'fuzzyw', 0 do |w|
  w.color = "#00FFFF"
  "STATUS BAR: "
end

I3::Bar.get_instance do |b|

  include I3::Bar::Widgets

  b.add_widgets [ STATUS_BAR, HOSTNAME, WIFI, TEMPERATURE ]

  b.add_event_callback do |e|
    $stderr.puts e.inspect
  end

  b.start_events_capturing
  b.run 1
end
