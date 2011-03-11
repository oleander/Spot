module SpotifyContainer
  class Base
    def initialize(args)
      args.keys.each { |name| instance_variable_set "@" + name.to_s.gsub(/[^a-z]/i, ''), args[name]}
    end
  end
end
