require "abstract"

module SpotifyContainer
  class Base
    attr_reader :popularity, :name
    
    def initialize(args)
      args.keys.each { |name| instance_variable_set "@" + name.to_s.gsub(/[^a-z]/i, ''), args[name]}
    end
    
    # Is the object it self valid?
    def valid?
      not_implemented
    end

    def available?(territory = nil)
      not_implemented
    end
    
    def href(type = "spotify")
      send("href_#{type}")
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