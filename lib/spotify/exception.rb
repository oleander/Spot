module SpotifyContainer
  class RequestLimitError < StandardError
    def initialize(url)
      super("The rate limiting for #{url} has kicked in.")
    end
  end
  
  class InvalidReturnTypeError < StandardError
    def initialize
      super("The data that was returned was not a valid JSON string")
    end
  end
end