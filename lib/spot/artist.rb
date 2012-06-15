require "spot/base"

module Spot
  class Artist < Spot::Base 
    def valid?; true; end
    
    protected
      def territories; []; end
    alias_method :to_s, :name
  end
end

