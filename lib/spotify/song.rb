require "lib/spotify/base"

module SpotifyContainer
  class Song < SpotifyContainer::Base
    def valid?
      true
    end
    
    def available?(territory = nil)
      territories.include?(territory)
    end
    
    def artist
      @artist ||= SpotifyContainer::Artist.new(@artists.first)
    end
    
    private
      def territories
        @territories ||= @album["availability"]["territories"].split(" ")
      end
  end
end