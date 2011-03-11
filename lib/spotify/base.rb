require "abstract"

module SpotifyContainer
  class Base
    attr_reader :popularity, :name, :href
    
    def initialize(args)
      args.keys.each { |name| instance_variable_set "@" + name.to_s.gsub(/[^a-z]/i, ''), args[name]}
    end
    
    # Is the object it self valid?
    def valid?
      not_implemented
    end

    def available?(territory = nil)
      not_implemented
    end
  end
end
