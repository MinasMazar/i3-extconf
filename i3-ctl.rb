#!/bin/env ruby

require 'json'

class I3API

  [ :get_workspaces, :get_outputs, :get_tree, :get_marks, :get_bar_config, :get_version ].each do |meth|
    define_method meth do
      i3send '-t', meth
    end
  end

  def current_workspace
    get_workspaces.find {|w| w["focused"] == true }
  end

  private

  def i3send(*msg)
    msg = msg.join(" ")
    ret = `i3-msg #{msg}`
    JSON.parse ret
  end

end

