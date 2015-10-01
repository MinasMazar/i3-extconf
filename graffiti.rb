
#exit(-1) if ARGV.empty?

def rand_image
  imgs = Dir[File.expand_path("../../Immagini/Wallpapers/", __FILE__)+"/*.jpg"]
  rand_wallpaper = imgs.sample
  system "ln -fs #{rand_wallpaper} wallpaper_graffiti"
end

rand_image if ARGV.include? "rand"
system "feh --bg-scale ~/.i3/wallpaper_graffiti"
