# -*- encoding : utf-8 -*-
require "spot/song"
require "spot/artist"
require "spot/album"
require "spot/prime"
require "spot/clean"
require "json"
require "rest-client"
require "charlock_holmes/string"
require "yaml"
require "uri"

module Spot
  class Search
    def initialize
      @methods = {
        :artists => {
          :selector => :artists,
          :class    => Spot::Artist,
          :url      => generate_url("artist")
        }, 
        :songs => {
          :selector => :tracks,
          :class    => Spot::Song,
          :url      => generate_url("track")
        },
        :albums => {
          :selector => :albums,
          :class    => Spot::Album,
          :url      => generate_url("album")
        }
      }
      
      @cache = {}
      
      @exclude = YAML.load(File.read("#{File.dirname(__FILE__)}/spot/ignore.yml"))
      
      @config = {
        :exclude    => 2,
        :popularity => 7,
        :limit      => 0.7,
        :offset     => 10
      }
      
      @options = {}
    end
    
    def self.method_missing(method, *args, &blk)
      Spot::Search.new.send(method, *args, &blk)
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
      unless @prime
        @_results ||= scrape.select(&:valid?)
      else
        @_results ||= scrape
      end
    end
    
    def strip
      tap { @strip = true }
    end
    
    def territory(value)
      tap { @options.merge!(:territory => value) }
    end
    
    def result
      if @prime
        Spot::Prime.new(results.sort_by(&:popularity).reverse[0..6], search).
          results.
          select(&:valid?).
          first
      else
        results.select(&:valid?).first
      end
    end

    #
    # @value String To be cleaned
    # @return String A cleaned string
    #
    def clean!(value)
      Spot::Clean.new(value).process
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
          @cache[@type] << item if item.valid? or @prime
        end
        @cache[@type]
      end
      
      def content
        data = download

        if encoding = data.detect_encoding[:encoding]
          data = download.force_encoding(encoding)
        else
          data = download.strip
        end

        JSON.parse(data)
      rescue ArgumentError
        JSON.parse(download)
      end
      
      def download
        @download ||= RestClient.get(url, :timeout => 10)
      end
      
      def errors(error)
        case error.to_s
        when "403 Forbidden"
          raise Spot::RequestLimitError.new(url)
        else
          raise error
        end
      end
      
      def generate_url(type)
        "http://ws.spotify.com/search/1/#{type}.json?q=<SEARCH>&page=<PAGE>"
      end
    end
end