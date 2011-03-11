require "lib/spotify/base"

module SpotifyContainer
  class Song < SpotifyContainer::Base
    attr_reader :length
    attr_writer :territory
    
    # Is valid if the territory exists or if no territory is given
    def valid?
      available?(@territory) or !@territory
    end
    
    def available?(territory = nil)
      territories.include?(territory)
    end
    
    def artist
      @_artist ||= SpotifyContainer::Artist.new(@artists.first)
    end
    
    def album
      @_album ||= SpotifyContainer::Album.new(@album)
    end
    
    # Returns a value from 0 to 1
    # The return type if float
    def popularity
      @_popularity ||= @popularity.to_f
    end
    
    private
      def territories
        @_territories ||= @album["availability"]["territories"].split(" ")
      end
  end
end