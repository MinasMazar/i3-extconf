#!/bin/env ruby

class I3Bar
  def initialize
    @widgets = {}
    init_widgets
  end

  def to_s
    refresh_widgets
    @widgets.values.map(&:chomp).join(" | ").to_s
  end

  def to_stdout
    $stdout.write to_s + "\n"
  end

  def stdout_attach(sec)
    loop do
      to_stdout
      $stdout.flush
      sleep sec
    end
  end

  private

  def init_widgets
    @widgets[:curr_play] = nil
    @widgets[:hostname] = [`whoami`, '@',  `hostname`].map(&:chomp).join
    @widgets[:time] = nil
  end

  def refresh_widgets
    xmms2_status = `xmms2 current --format '${artist} - ${title} (${playback_status})'`.chomp
    if xmms2_status =~ /(Stopped)/
      xmms2_status = "[No playing]"
    else
      xmms2_status = "[#{xmms2_status}]"
    end

    @widgets[:curr_play] = xmms2_status
    @widgets[:time] = Time.new.strftime('%d-%m-%Y %H:%M:%S')
  end

end

I3Bar.new.stdout_attach(5)
