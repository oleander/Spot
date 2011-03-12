require "lib/spotify/base"

module SpotifyContainer
  class Artist < SpotifyContainer::Base 
    def valid?; true; end
    def available?(territory = nil); true; end
  end
end

