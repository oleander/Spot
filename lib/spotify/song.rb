require "./lib/spotify/base"

module SpotifyContainer
  class Song < SpotifyContainer::Base
    attr_reader :length
    attr_writer :territory
    
    # Is valid if the territory exists or if no territory is given
    def valid?
      available?(@territory) or !@territory
    end
    
    def artist
      @_artist ||= SpotifyContainer::Artist.new(@artists.first)
    end
    
    def album
      @_album ||= SpotifyContainer::Album.new(@album)
    end
    
    def to_s
      @_to_s = "#{title} - #{artist.name}"
    end
    
    protected
      def territories
        @_territories ||= @album["availability"]["territories"].split(" ")
      end
    
    alias_method :title, :name
  end
end