
require 'json'

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

    def goto_workspace(ws = :back_and_forth)
      ws = 'back_and_forth' if ws == :back_and_forth
      i3cmd "workspace #{ws}"
    end

    def move_to_workspace(ws)
      i3cmd "move container to workspace #{ws}"
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
      $stderr.puts "i3 send :: [ #{msg} ] => #{ret}" if @debug
      ret
    end
  
  end
  
  module ExtendedAPI

    include API

    def get_workspaces
      super.map {|w| w["name"] }
    end

    def goto_workspace(ws)
      if ws ==  'autonext'
        last_ws = get_workspaces.last
        ws = last_ws.succ
      end
      super ws
    end

    alias :move_to_workspace :goto_workspace

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

@driver = Object.new.extend(I3::ExtendedAPI)
@driver.instance_variable_set :@debug, false
if ARGV.any?
  cmd = ARGV.map { |arg| arg == "_stdin_" ? $stdin.readline.chomp : arg }
  puts @driver.send *cmd
end
