require "spot/base"

module Spot
  class Album < Spot::Base
    def valid?
      available?(@territory) or !@territory
    end
    
    def artist
      @_artist ||= Spot::Artist.new(@artists.first)
    end
    
    protected
      def territories
        @availability["territories"].split(" ")
      end
    alias_method :to_s, :name
  end
end
