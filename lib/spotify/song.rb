module SpotifyContainer
  class Song
    def initialize(args)
       args.keys.each { |name| instance_variable_set "@" + name.to_s, args[name] unless name.match /[^a-z]/}
    end
    
    def valid?
      true
    end
  end
end
  