require "lib/spotify/base"

module SpotifyContainer
  class Song < SpotifyContainer::Base
    def valid?
      true
    end
  end
end
  