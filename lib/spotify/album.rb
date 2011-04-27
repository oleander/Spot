require "./lib/spotify/base"

module SpotifyContainer
  class Album < SpotifyContainer::Base
    def valid?
      available?(@territory) or !@territory
    end
    
    def artist
      @_artist ||= SpotifyContainer::Artist.new(@artists.first)
    end
    
    protected
      def territories
        @availability["territories"]
      end
    alias_method :to_s, :name
  end
end
