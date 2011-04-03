require "json/pure"
require "rest-client"
require "uri"
require "levenshteinish"
require "spotify/song"
require "spotify/artist"
require "spotify/album"
require "rchardet19"
require "iconv"
require "yaml"

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
    
    @exclude = YAML.load(File.read("#{File.dirname(__FILE__)}/spotify/exclude.yml"))
    
    @config = {
      :exclude => 2,
      :popularity => 10,
      :limit => 0.7
    }
    
    @options = {}
  end
  
  def self.method_missing(method, *args, &blk)
    Spotify.new.send(method, *args, &blk)
  end
  
  def method_missing(method, *args, &blk)
    if method.to_s =~ /^find(_all)?_([a-z]+)$/i 
      find($2, !!$1, args.first)
    elsif scrape and content["info"].keys.include?(method.to_s)
       content["info"][method.to_s]
    else
      super(method, *args, &blk)
    end
  end
  
  def page(value)
    tap { @page = value }
  end
  
  def prime
    tap { @prime = true }
  end
  
  def find(type, all, s)
    @search = s
    @type = all ? type.to_sym : "#{type}s".to_sym
    raise NoMethodError.new(@type) unless @methods.keys.include?(@type)
    self
  end
  
  def results
    @_results ||= scrape
  end
  
  def strip
    tap { @strip = true }
  end
  
  def territory(value)
    tap { @options.merge!(:territory => value) }
  end
  
  def result 
    @prime ? results.map do |r|
      [(
        if @search.split("-").count == 1
          points = Levenshtein.distance(clean!(@search), clean!(r.to_s))
        else
          if @type == :songs
            artist = r.artist.name
            song = r.name
          elsif @type == :artists
            artist = r.name
            song = r.song.title
          else
            artist = r.artist
            song = ""
          end
          
          points = Levenshtein.distance(clean!(@search.split("-").first), clean!(artist))
          points += Levenshtein.distance(clean!(@search.split("-").last), clean!(song))
        end

        points - r.popularity/@config[:popularity]
      ), r]
    end.reject do |distance, value|
      exclude?(value.to_s)
    end.sort_by do |distance, _|
      distance
    end.map(&:last).first : results.first
  end
  
  def clean!(string)
    string.strip!
    
    # Song - A + B + C => Song - A
    # Song - A abc/def => Song - A abc
    # Song - A & abc def => Song - A
    # Song - A "abc def" => Song - A
    # Song - A [B + C] => Song - A
    # Song A B.mp3 => Song A B
    # Song a.b.c.d.e => Song a b c d e
    # 10. Song => Song
    [/\.[a-z0-9]{2,3}$/, /\[[^\]]*\]/,/".*"/, /'.*'/, /[&|\/|\+][^\z]*/, /^\d+(\.)?/].each do |reg|
      string = string.gsub(reg, '').strip
    end
    
    [/\(.+?\)/m, /feat(.*?)\s*[^\s]+/i, /[-]+/, /[\s]+/m, /\./, /\_/].each do |reg|
       string = string.gsub(reg, ' ').strip
    end

    string.gsub(/\A\s|\s\z/, '').gsub(/\s+/, ' ').strip.downcase
  end
  
  def exclude?(compare)
    @exclude.map { |value| !! compare.match(/#{value}/i) }.any?
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
        item = @methods[@type][:class].new(item.merge(@options)) 
        @cache[@type] << item if item.valid?
      end
      
      @cache[@type]
    end
    
    def content
      data = download
      cd = CharDet.detect(data)
      data = cd.confidence > 0.6 ? Iconv.conv(cd.encoding, "UTF-8", data) : data
      @content ||= JSON.parse(data)
    end
    
    def download
      @download ||= RestClient.get(url, :timeout => 10)
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