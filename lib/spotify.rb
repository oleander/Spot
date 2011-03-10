require "json/pure"
require "rest-client"
require "lib/spotify/song"
require "lib/spotify/artist"
require "lib/spotify/album"

class Spotify
  attr_writer :url
  
  def initialize
    @methods = {
      :artists => {
        :selector => :artists,
        :class => SpotifyContainer::Artist
      }, 
      :songs => {
        :selector => :tracks,
        :class => SpotifyContainer::Song
      },
      :albums => {
        :selector => :albums,
        :class => SpotifyContainer::Album
      }
    }
    
    @cache = {}
  end
  
  def method_missing(method, *args, &block)
    @methods.keys.include?(method) ? scrape(method.to_sym) : super(method, *args, &block)
  end
  
  private
    
    def scrape(type)
      return @cache[type] if @cache[type]
      
      @cache[type] = []; content[@methods[type][:selector].to_s].each do |item|
        item = @methods[type][:class].new(item) 
        @cache[type] << @cache[type] if item.valid?
      end
      
      @cache[type]
    end
    
    def content
      @content ||= JSON.parse(download)
    end
    
    def download
      @download ||= RestClient.get @url, :timeout => 10
    end
end