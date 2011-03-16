require "json/pure"
require "rest-client"
require "uri"
require "levenshteinish"
require "spotify/song"
require "spotify/artist"
require "spotify/album"
require "spotify/exception"
require "spotify/error"

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
    method.to_s =~ /^find(_all)?_(.+)$/ ? find($2, !!$1, args.first) : super(method, *args, &blk)
  end
  
  def page(value)
    @page = value; self
  end
  
  def prime
    @prime = self
  end
  
  def find(type, all, s)
    @search = s
    @type = all ? type.to_sym : "#{type}s".to_sym
    self
  end
  
  def results
    @_results ||= scrape
  end
  
  def strip
    @strip = self
  end
  
  def result      
    @prime ? results.sort_by{ |r| Levenshtein.distance(search(true), clean!(r.to_s)) }.first : results.first
  end
  
  private
    def url
      @url ||= @methods[@type][:url].
        gsub(/<SEARCH>/, URI.escape(search)).
        gsub(/<PAGE>/, (@page || 1).to_s)
    end
  
    def search(force = false)
      @_search ||= ((@strip or force) ? clean!(@search) : @search)
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
    rescue StandardError => error
      raise SourceHasBeenChangedError.new(error, url)
    end
    
    def download
      @download ||= RestClient.get url, :timeout => 10
    rescue StandardError => request
      errors(request)
    end
    
    def clean!(string)
      string.strip!
      
      # Song - A + B + C => Song - A
      # Song - A abc/def => Song - A abc
      # Song - A & abc def => Song - A
      # Song - A "abc def" => Song - A
      # Song - A [B + C] => Song - A
      # Song A B.mp3 => Song A B
      # 10. Song => Song
      [/\.[a-z0-9]{2,3}$/, /\[[^\]]*\]/,/".*"/, /'.*'/, /[&|\/|\+][^\z]*/, /^\d+(\.)?/].each do |reg|
        string = string.gsub(reg, '').strip
      end
      
      [/\(.+?\)/m, /feat(.*?)\s*[^\s]+/i, /[-]+/, /[\s]+/m].each do |reg|
         string = string.gsub(reg, ' ').strip
      end

      string.gsub(/\A\s|\s\z/, '').gsub(/\s+/, ' ').strip.downcase
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