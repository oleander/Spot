require "spot/base"

module Spot
  class Song < Spot::Base
    attr_reader :length
    attr_writer :territory
    
    # Is valid if the territory exists or if no territory is given
    def valid?
      available?(@territory) or !@territory
    end
    
    def artist
      @_artist ||= Spot::Artist.new(@artists.first)
    end
    
    def album
      @_album ||= Spot::Album.new(@album)
    end
    
    def to_s
      "#{artist.name} - #{title}"
    end
    
    protected
      def territories
        @album["availability"]["territories"].split(" ")
      end
    
    alias_method :title, :name
  end
end