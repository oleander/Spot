require "spec_helper"
require "lib/spotify/artist"

describe SpotifyContainer::Artist do
  before(:each) do
    @artist = SpotifyContainer::Artist.new(JSON.load(File.read("spec/fixtures/artist.json"))["artists"].first)
  end
end