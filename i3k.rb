#!/bin/ruby

require 'i3rb'
require 'rerun'

module I3::Macros

  include I3::API
  include I3::CLI
  include I3::DMenu

  attr_accessor :repl_mode
  def repl_mode?
    @repl_mode
  end

  def repl_mode
    @repl_mode = true
  end

  def pop_mode
    @repl_mode = false
  end

  def dmenu_loop
    @entries = []
    loop do
      cmd = get_string.chomp
      $logger.debug "DMENU: #{cmd}"
      break if cmd == '' || cmd =~ /quit|exit/
      ret = self.send cmd
      if ret != "" && repl_mode?
        @entries = [ ret ]
      else
        @entries << ret
      end
      sleep 0.01
    end
  end

  def goto_outpad
    goto_workspace "OUTPAD"
  end

  def get_workspace_names
    get_workspaces.map {|w| w["name"] }
  end

  def wallpaper_rerun
    Kernel.fork do
      system "rvm default do rerun -sb -p wallpaper \"feh --bg-scale ~/.i3/wallpaper\" "
    end
  end

end

include I3::Macros

run
