#!/bin/ruby

require 'i3rb'

class I3::Kommando

  include I3::API

  @@main = I3::DMenu.get_instance
  @@main.lines = 10
  @@main.position = :bottom

  def initialize
    @modes = { :main => @@main }
    @cur = @modes[:main]
  end

  def run
    loop do
      dmenu_ret = @cur.run
      break if dmenu_ret.value == 'break'
      puts self.instance_eval dmenu_ret.value
    end
  end
    
end

I3::Kommando.new.run