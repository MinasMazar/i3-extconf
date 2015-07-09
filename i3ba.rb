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
    hostname_w = Widget.new :hostname, 0, :pos => 1 do
      [`whoami`, '@',  `hostname`].map(&:chomp).join
    end
    random_w = Widget.new :random, 4, :pos => 2, :active => false do
      ( ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a ).shuffle.join
    end
    time_w = Widget.new :time, 1, :pos => 4 do
      Time.new.strftime('%d-%m-%Y %H:%M:%S')
    end
    wifi_w = Widget.new :wifi, 10, :pos => 3 do
      out = `iwconfig`.gsub("\n", " ")
      if md = out.match(/ESSID:"(.+)"/)
        "WiFi: #{md[1]}"
      else
        "WiFi: down"
      end
    end
    @widgets = [ hostname_w, random_w, time_w, wifi_w ]
    @widgets.sort_by! {|w| w.pos }
  end

  def run_widgets
    @widgets.each { |w| w.run if w.active? }
  end

end

I3Bar.new.stdout_attach(1)
