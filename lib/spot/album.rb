require "spot/base"

module SpotContainer
  class Album < SpotContainer::Base
    def valid?
      available?(@territory) or !@territory
    end
    
    def artist
      @_artist ||= SpotContainer::Artist.new(@artists.first)
    end
    
    protected
      def territories
        @availability["territories"]
      end
    alias_method :to_s, :name
  end
end
