require "lib/spotify/base"

module SpotifyContainer
  class Artist < SpotifyContainer::Base 
    def valid?; true; end
    
    protected
      def territories; []; end
  end
end

