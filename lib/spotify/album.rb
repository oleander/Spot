require "lib/spotify/base"

module SpotifyContainer
  class Album < SpotifyContainer::Base
    def valid?
      true
    end
  end
end
