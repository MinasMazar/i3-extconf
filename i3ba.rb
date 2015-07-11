#!/bin/env ruby

class I3Bar

  class Widget
    def initialize(name, timeout, options = {}, &proc)
      @name = name
      @text = "..."
      @active = true
      @options = options
      self.timeout = timeout
      self.set_proc(&proc)
    end
    def pos
      @options[:pos] || -1
    end
    def active?
      @options[:active] != false
    end
    def set_proc(&proc)
      @proc = proc
    end
    attr_accessor :timeout, :active
    def stop
      @run_th && @run_th.kill
    end
    def run
      @run_th = Thread.new do
        loop do
          #@text = binding.call @proc
          @text = @proc.call
          break if @timeout.to_i <= 0
          sleep @timeout.to_i
        end
      end
    end
    def eval
      active? ? @text : ''
    end
  end

  def initialize
    @widgets = []
    init_widgets
    run_widgets
  end

  def to_s
    @widgets.map(&:eval).map(&:chomp).join(" | ").to_s
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
    @widgets << ( Widget.new :hostname, 0, :pos => 1 do
      [`whoami`, '@',  `hostname`].map(&:chomp).join
    end )
    @widgets << ( Widget.new :audacious, 6, :pos => 20 do
      path = File.expand_path '../audacious_current_track.txt', __FILE__
      File.read path
    end )
    @widgets << ( Widget.new :random, 4, :pos => 31, :active => false do
      ( ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a ).shuffle.join
    end )
    @widgets << ( Widget.new :time, 1, :pos => 40 do
      Time.new.strftime('%d-%m-%Y %H:%M:%S')
    end )
    @widgets << ( Widget.new :wifi, 10, :pos => 30 do
      iwc_out = `iwconfig`.gsub("\n", " ")
      out = "WiFi: "
      if md = iwc_out.match(/ESSID:"(.+)"/)
        out += "#{md[1]} "
      else
        out += "down "
      end
      if md = iwc_out.match(/Link Quality=(\d+)\/(\d+)/)
        signal, range = md[1].to_i, md[2].to_i
        signal_percent = signal * 100 / range
        out += " (#{signal_percent}%) "
      end
      out
    end )
    @widgets.sort_by! {|w| w.pos }
  end

  def run_widgets
    @widgets.each { |w| w.run if w.active? }
  end

end

I3Bar.new.stdout_attach(1)
