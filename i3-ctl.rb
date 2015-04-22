#!/bin/env ruby

require 'json'
require 'thor'

module I3
  module API
  
    [ :get_workspaces, :get_outputs, :get_tree, :get_marks, :get_bar_config, :get_version ].each do |meth|
      define_method meth do
        i3send '-t', meth
      end
    end
  
    def current_workspace
      get_workspaces.find {|w| w["focused"] == true }
    end
  
    def i3cmd(cmd)
      i3send cmd
    end
  
    protected
  
    def i3send(*msg)
      msg = msg.join(", ")
      print "i3) sending #{msg} => "
      ret = `i3-msg #{msg}`
      puts ret.inspect
      JSON.parse ret
    end
  
  end
  
  module Macros

    include API

    def spiral(args)
      dir = 'h'
      #args.map {|a| [ a, "split #{dir = dir == 'v' ? 'h' : 'v'}" ] }.flatten
      args.flatten.inject([]) {|arr, a| arr + [ a, "split #{dir = dir == 'v' ? 'h' : 'v' }"] }
    end
  
    def gotow_and_start_nterms(workspace, nterms)
      i3send  [
        "workspace #{workspace}",
        spiral([ 'exec x-terminal-emulator'] * nterms)
      ]
    end
  
  end

end

class I3CLI < Thor
  include I3::Macros

  desc "massterm", "Move to <workspace (def.8)> and start <terms (def.3)> terms."
  option :workspace, :default => 8
  option :terms, :default => 3
  def massterm
    gotow_and_start_nterms(options[:workspace], options[:terms])
  end

  desc "phalanx", "Start phalanx-prybot sessions."
    def phalanx
      i3send [
        "workspace 9:PHALANX", "split h",
        "exec 'x-terminal-emulator -x rvm default do phalanx-prybot.rb S126_IT' ",
        "exec 'x-terminal-emulator -x rvm default do phalanx-prybot.rb S114_IT' ",
        "workspace back_and_forth"
      ]
    end 
end

args = ARGV
args = `echo massterm | dmenu`.chomp.split if args.empty?
I3CLI.start args

