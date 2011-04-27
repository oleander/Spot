require "./lib/spot/base"

module SpotContainer
  class Artist < SpotContainer::Base 
    def valid?; true; end
    
    protected
      def territories; []; end
    alias_method :to_s, :name
  end
end

