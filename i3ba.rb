#!/bin/env ruby

require 'i3rb'

bar = I3::Bar.get_instance
bar.add_widgets I3::Bar::Widgets::BASIC
bar.run 1