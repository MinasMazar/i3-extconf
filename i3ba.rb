#!/bin/env ruby

class I3Bar

  class Widget
    def initialize(timeout, &proc)
      @text = "..."
      @active = true
      self.timeout = timeout
      self.set_proc(&proc)
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
      @active ? @text : ''
    end
  end

  def initialize
    @widgets = {}
    init_widgets
    run_widgets
  end

  def to_s
    @widgets.values.map(&:eval).map(&:chomp).join(" | ").to_s
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
    @widgets[:hostname] = Widget.new 0 do
      [`whoami`, '@',  `hostname`].map(&:chomp).join
    end
    @widgets[:random] = Widget.new 4 do
      ( ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a ).shuffle.join
    end
    @widgets[:time] = Widget.new 1 do
      Time.new.strftime('%d-%m-%Y %H:%M:%S')
    end
  end

  def run_widgets
    @widgets.values.each { |w| w.run }
  end

end

I3Bar.new.stdout_attach(1)
