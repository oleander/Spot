require "spotify/base"

module SpotifyContainer
  class Artist < SpotifyContainer::Base 
    def valid?; true; end
    
    protected
      def territories; []; end
    alias_method :to_s, :name
  end
end

