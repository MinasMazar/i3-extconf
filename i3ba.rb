#!/bin/env ruby

require 'i3rb'

include I3::API
@stack_mode = true
@split_dir = "v"

def cycle_split_dir
  @split_dir = @split_dir == 'v' ? 'h' : 'v'
end

bar = I3::Bar.get_instance
layoutb = I3::Bar::Widget.new "layout", 100, :color => "#AAFF22" do |b|
  "L"
end

layoutb.add_event_callback do |w, e|
  if e["button"] == 1
    if @stack_mode
      i3send "layout toggle split"
      @stack_mode = false
    else
      i3send "layout stacking"
      @stack_mode = true
    end
  elsif e["button"] == 3
    i3send "layout split #{ cycle_split_dir }"
  end
end


killb = I3::Bar::Widget.new "kill", 100, :color => "#AAFF22" do |b|
  "X"
end

killb.add_event_callback do |w, e|
  if e["button"] == 1
    i3send "kill"
  end
end

bar.add_widgets I3::Bar::Widgets::BASIC
bar.add_widget layoutb
bar.add_widget killb

tw = bar.widget "calendar"
tw.add_event_callback do |w, e|
  if e["button"] == 3
    system 'xfce4-terminal -H -e cal'
  end
end

bar.add_event_callback do |b, e|
  $stderr.puts e.inspect
end

bar.start_events_capturing
bar.run 1
