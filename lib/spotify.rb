require "json/pure"
require "rest-client"
require "uri"
require "lib/spotify/song"
require "lib/spotify/artist"
require "lib/spotify/album"
require "lib/spotify/exception"

class Spotify
  def initialize
    @methods = {
      :artists => {
        :selector => :artists,
        :class    => SpotifyContainer::Artist,
        :url      => generate_url("artist")
      }, 
      :songs => {
        :selector => :tracks,
        :class    => SpotifyContainer::Song,
        :url      => generate_url("track")
      },
      :albums => {
        :selector => :albums,
        :class    => SpotifyContainer::Album,
        :url      => generate_url("album")
      }
    }
    
    @cache = {}
  end
  
  def self.method_missing(method, *args, &blk)
    Spotify.new.send(method, *args, &blk)
  end
  
  def method_missing(method, *args, &blk)
    find($2, !!$1, args.first) if method.to_s =~ /^find(_all)?_(.+)$/
  end
  
  def page(value)
    @page = value; self
  end
  
  def prime
    @prime = self
  end
  
  def find(type, all, search)
    @search = search
    @type = all ? type.to_sym : "#{type}s".to_sym
    self
  end
  
  def results
    @_results ||= scrape
  end
  
  def result
    results.first
  end
  
  private
    def url
      @url ||= @methods[@type][:url].
        gsub(/<SEARCH>/, URI.escape(@search)).
        gsub(/<PAGE>/, (@page || 1).to_s)
    end
  
    def scrape
      return @cache[@type] if @cache[@type]
      
      @cache[@type] = []; content[@methods[@type][:selector].to_s].each do |item|
        item = @methods[@type][:class].new(item) 
        @cache[@type] << item if item.valid?
      end
      
      @cache[@type]
    end
    
    def content
      @content ||= JSON.parse(download)
    rescue JSON::ParserError
      raise SpotifyContainer::InvalidReturnTypeError.new
    end
    
    def download
      @download ||= RestClient.get url, :timeout => 10
    rescue StandardError => request
      errors(request)
    end
    
    def errors(error)
      case error.to_s
      when "403 Forbidden"
        raise SpotifyContainer::RequestLimitError.new(url)
      else
        raise error
      end
    end
    
    def generate_url(type)
      "http://ws.spotify.com/search/1/#{type}.json?q=<SEARCH>&page=<PAGE>"
    end
end