require "spotify/base"

module SpotifyContainer
  class Album < SpotifyContainer::Base
    def valid?; true; end
    
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
