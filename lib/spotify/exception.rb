module SpotifyContainer
  class RequestLimitError < StandardError
    def initialize(url)
      super("The rate limiting for #{url} has kicked in.")
    end
  end
end