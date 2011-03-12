require "lib/spotify/base"

module SpotifyContainer
  class Album < SpotifyContainer::Base
    def valid?
      true
    end
    
    def artist
      @_artist ||= SpotifyContainer::Artist.new(@artists.first)
    end
  end
end
