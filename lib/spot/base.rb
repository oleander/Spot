require "abstract"

module SpotContainer
  class Base
    attr_reader :name
    
    def initialize(args)
      args.keys.each { |name| instance_variable_set "@" + name.to_s.gsub(/[^a-z]/i, ''), args[name] }
    end
    
    # Is the object it self valid?
    def valid?
      not_implemented
    end
    
    # Is the object available in {territory}?
    # Where {territory} can be any string representation of the ISO 3166-1 alpha-2 table
    # Read more about it here: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
    # Sweden => SE
    # Norway => NO
    def available?(territory = nil)
      territories.include?(territory)
    end
    
    # Returns a URL for the object
    # {type} can contain the value "spotify" or "href"
    # href => http://open.spotify.com/track/5DhDGwNXRPHsMApbtVKvFb
    # spotify => spotify:track:5DhDGwNXRPHsMApbtVKvFb
    def href(type = "spotify")
      send("href_#{type}")
    end
    
    # Returns a string representation of the item
    def to_s
      not_implemented
    end
    
    # Returns a value from 0 to 1
    # The return type if float
    def popularity
      @_popularity ||= @popularity.to_f
    end
    
    protected
      def territories
        not_implemented
      end
      
    private
      def href_http
        "http://open.spotify.com/#{$1}/#{$2}" if href_spotify.to_s =~ /spotify:(\w+):(\w+)/
      end
      
      def href_spotify
        @href
      end
  end
end