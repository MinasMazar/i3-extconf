
#exit(-1) if ARGV.empty?

require 'pry'
require 'mechanize'

class HTTPClient
  @@http_agent = Mechanize.new
  def self.get(url)
    @@http_agent.get url
  end
  def self.get_page(url)
    get(url).body
  end
end

def rand_image
  imgs = Dir[File.expand_path("../../Immagini/Wallpapers/", __FILE__)+"/*.jpg"]
  return false if imgs.empty?
  rand_wallpaper = imgs.sample
  system "ln -fs #{rand_wallpaper} wallpaper_graffiti"
end

def apod_image
  dates = ( (Date.today - 365) .. Date.today ).to_a
  date = dates.sample.strftime "%Y-%m-%d"
  url = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&date=#{date}&hd=false"
  result = JSON.parse HTTPClient.get_page url
  if result["media_type"] == "image"
    img = HTTPClient.get_page result["url"]
    File.write "wallpaper_graffiti", img
  else
    raise "Could not download media type: #{result["media_type"]}"
  end
end

case ARGV.first
when "rand"
  rand_image
when "apod"
  apod_image
end

system "feh --bg-scale ~/.i3/wallpaper_graffiti"
