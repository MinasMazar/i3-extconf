
#exit(-1) if ARGV.empty?

imgs = Dir[File.expand_path("../../Immagini/", __FILE__)+"/*.jpg"]
rand_wallpaper = imgs.sample
# system "ln -fs #{rand_wallpaper} wallpaper_graffiti"
system "feh --bg-scale ~/.i3/wallpaper_graffiti"
