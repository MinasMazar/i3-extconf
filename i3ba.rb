#!/bin/env ruby
require 'pry'
require 'i3rb'

include I3::API
@layout = "s"
@split_dir = "v"

def cycle_split_dir
  @split_dir = @split_dir == 'v' ? 'h' : 'v'
end

I3::Bar.get_instance do |b|

  b.add_widgets I3::Bar::Widgets::BASIC

  tw = b.widget "calendar"
  tw.add_event_callback do |w, e|
    if e["button"] == 3
      system 'xfce4-terminal -H -e cal'
    end
  end

  b.add_event_callback do |e|
    $stderr.puts e.inspect
  end

  b.start_events_capturing
  b.run 1
end
