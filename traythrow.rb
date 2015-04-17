
#-----------------------------------------------------------------------------
# Summary: Runs a system tray application with ability to take a screenshot
#-----------------------------------------------------------------------------

# Import the Java class libraries we wish to use
include Java
import java.awt.TrayIcon
import java.awt.Toolkit

class TrayApp
  def self.create_item(title)
    java.awt.MenuItem.new(title)
  end
  def self.get_image(path)
    java.awt.Toolkit::default_toolkit.get_image(path)
  end
  def self.create_icon(caption, image, popup)
    tray_icon = TrayIcon.new(image, caption, popup)
    tray_icon.image_auto_size = true
    tray_icon
  end

  def initialize(caption, image_icon_path)
    @popup_items = []
    @caption = caption
    @image_icon = TrayApp.get_image image_icon_path
  end

  def append_item(title, type = :normal, &action)
    item = TrayApp.create_item title
    if type == :exit
      item.add_action_listener { java.lang.System::exit(0) }
    elsif type == :normal
      item.add_action_listener &action
    end
    @popup_items << item
  end

  def tray_it!
    tray_icon = TrayApp.create_icon @caption, @image_icon, create_popup
    @tray = java.awt.SystemTray::system_tray
    @tray.add(tray_icon)
  end

  private
  def create_popup
    popup = java.awt.PopupMenu.new
    @popup_items.each do |m|
      popup.add m
    end
    popup
  end
end

def spawn_app cmd
  system cmd
end

tray_app = TrayApp.new('Little JRuby Tray Application', './rlauncher.png')
tray_app.append_item('Exit', :exit) {}
tray_app.append_item('Terminal') { spawn_app 'x-terminal-emulator' }
tray_app.append_item('Lock screen') { spawn_app 'xflock4' }
tray_app.append_item('File manager') { spawn_app 'thunar' }
tray_app.append_item('About..') { }

tray_app.tray_it!
