#!/bin/env ruby

require 'json'
require 'thor'
require 'pry'

module I3
  module API
  
    [ :get_workspaces, :get_outputs, :get_tree, :get_marks, :get_bar_config, :get_version ].each do |meth|
      define_method meth do
        i3send "-t #{meth}"
      end
    end
  
    def current_workspace
      get_workspaces.find {|w| w["focused"] == true }
    end

    def current_workspaces
      get_outputs.select {|o| o["current_workspace"] != nil }
    end

    def get_active_outputs
      get_outputs.select {|o| o["active"] == true }
    end

    def goto_workspace(ws)
      i3cmd "workspace #{ws}"
    end

    def goto_output(out)
      i3cmd "focus output #{out}"
    end

    def exec(cmd)
      i3cmd "exec \"#{cmd}\""
    end

    def i3cmd(cmd)
      i3send cmd
    end
  
    protected
  
    def i3send(*msg)
      msg = msg.join(", ")
      ret = JSON.parse `i3-msg #{msg}`
      puts "i3 send :: [ #{msg} ] => #{ret}"
      ret
    end
  
  end
  
  module Macros

    include API

    def goto_and_hold_workspace(ws = nil)
      goto_workspace ws if ws
      i3cmd "exec xmessage \"WORKSPACE-HOLDER\""
    end

    def spiral(args)
      dir = 'h'
      #args.map {|a| [ a, "split #{dir = dir == 'v' ? 'h' : 'v'}" ] }.flatten
      args.flatten.inject([]) {|arr, a| arr + [ a, "split #{dir = dir == 'v' ? 'h' : 'v' }"] }
    end

    def goto_outpads
      get_active_outputs.each do |output|
        goto_output output["name"]
        goto_workspace "#{output["name"]}:OUTPAD"
      end
    end
  
    def gotow_and_start_nterms(workspace, nterms)
      i3send  [
        "workspace #{workspace}",
        spiral([ 'exec x-terminal-emulator'] * nterms)
      ]
    end
  
  end

end

class SubcommandExampleCLI < Thor

  desc "subcommand", "subcommand action"
  def subcommand
    puts "#{self.class}##{__method__}"
  end
end
  
class I3CLI < Thor
  include I3::Macros

  desc "massterm", "Move to <workspace (def.8)> and start <terms (def.3)> terms."
  option :workspace, :default => 8
  option :terms, :default => 3
  def massterm
    i3cmd ["exec x-terminal-emulator", "exec x-terminal-emulator", "split v", "exec x-terminal-emulator", "split h" ]
  end

  desc "phalanx", "Start phalanx-prybot sessions."
  def phalanx
    i3cmd [
      "workspace 9:PHALANX", "split h",
      "exec 'x-terminal-emulator -x rvm default do phalanx-prybot.rb S126_IT' ",
      "exec 'x-terminal-emulator -x rvm default do phalanx-prybot.rb S114_IT' ",
      "workspace back_and_forth"
     ]
  end

  desc "bells", "Bells of Pescolanciano give us the current time."
  def bells(action)
    system "rvm default exec pescobells #{action}"
  end

  desc "subcommand", "Thor CLI: Subcommand example"
  subcommand "subcommand", SubcommandExampleCLI

  desc "outpad", "Escape current workspaces for all outputs"
  def outpad
    goto_outpads
  end

  desc "media", "Launch media compliant"
  def media
    goto_workspace "3:MEDIA"
    i3cmd [ "split v" ]
    exec "gxmms2"
    exec "x-terminal-emulator -x alsamixer"
    goto_workspace :back_and_forth
  end

  desc "pry", "Start PRY session inside CLI"
  def pry
    binding.pry
  end

end

args = ARGV
args = `echo massterm | dmenu`.chomp.split if args.empty?
I3CLI.start args

