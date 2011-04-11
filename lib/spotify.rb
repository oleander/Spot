# -*- encoding : utf-8 -*-

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
      :exclude    => 2,
      :popularity => 7,
      :limit      => 0.7,
      :offset     => 10
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
  
  def prefix(value)
    tap { @prefix = value }
  end
  
  def find(type, all, s)
    tap {
      @search = s
      @type = all ? type.to_sym : "#{type}s".to_sym
      raise NoMethodError.new(@type) unless @methods.keys.include?(@type)
    }
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
      
      song, artist = type_of(r)
      
      match = "#{song} #{artist}".split(" ")
      raw = clean!(search).split(" ")

      if raw.length < match.length
        diff = match - raw
        res = diff.length.to_f/match.length
      else
        diff = raw - match
        res = diff.length.to_f/raw.length
      end

      if diff.length > 1 and not match.map{ |m| diff.include?(m) }.all?
        res =+ diff.map do |value|
          match.map do |m|
            Levenshtein.distance(value, m)
          end.inject(:+)
        end.inject(:+) / @config[:offset]
      end
      
      [res - r.popularity/@config[:popularity], r]
    end.reject do |distance, value|
      exclude?(value.to_s)
    end.sort_by do |distance, _|
      distance
    end.map(&:last).first : results.first
  end
  
  def type_of(r)
    if @type == :songs
      return r.name.to_s, r.artist.name.to_s
    elsif @type == :artists
      return r.song.title.to_s, r.name.to_s
    else
      return "", r.artist.to_s
    end
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
    [/\.[a-z0-9]{2,3}$/, /\[[^\]]*\]/,/".*"/, /'.*'/, /[&|\/|\+][^\z]*/, /^(\d+.*?[^a-z]+?)/i].each do |reg|
      string = string.gsub(reg, '').strip
    end
    
    [/\(.+?\)/m, /feat(.*?)\s*[^\s]+/i, /[-]+/, /[\s]+/m, /\./, /\_/].each do |reg|
       string = string.gsub(reg, ' ').strip
    end
    
    {"ä" => "a", "å" => "a", "ö" => "o"}.each do |from, to|
      string.gsub!(/#{from}/i, to)
    end
    
    string.gsub(/\A\s|\s\z/, '').gsub(/\s+/, ' ').strip.downcase
  rescue Encoding::CompatibilityError
    return string
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
      return @_search if @_search
      @_search = ""
      @_search = ((@strip or force) ? clean!(@prefix) + " " : @prefix + " ") if @prefix
      @_search += ((@strip or force) ? clean!(@search) : @search)
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