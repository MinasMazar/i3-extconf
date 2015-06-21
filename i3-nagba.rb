
class Nagbar

  Button = Struct.new :title, :cmd

  attr_accessor :menu, :buttons, :font

  def initialize
    @buttons = []
    @font = "-misc-fixed-medium-r-normal--13-120-75-75-C-70-iso10646-1"
  end
  def add_button(title, cmd)
    @buttons << Button.new(title, cmd)
  end
  def start
    cmd_txt = "i3-nagbar -t warn -f #{@font} -m #{@msg} "
    @buttons.each {|b| cmd_txt += " -b \"#{b.title}\" \"#{b.cmd}\"" }
    system cmd_txt
  end
end

class NagMenu < Nagbar

  def initialize
    super
    @msg = "NagMenu"
    add_button "Xfce Menu", "xfce4-appfinder"
  end
end

if $0 == __FILE__
  NagMenu.new.start
end

