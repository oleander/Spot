require "lib/spotify/base"

module SpotifyContainer
  class Song < SpotifyContainer::Base
    attr_reader :length
    
    def valid?
      true
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
    
    private
      def territories
        @_territories ||= @album["availability"]["territories"].split(" ")
      end
  end
end