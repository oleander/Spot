require "spec_helper"
require "lib/spotify/artist"

describe SpotifyContainer::Artist do
  before(:each) do
    @artist = SpotifyContainer::Artist.new(JSON.load(File.read("spec/fixtures/artist.json"))["artists"].first)
  end
  
  it "should always be valid" do
    @artist.should be_valid
  end
  
  it "should always be available" do
    @artist.should be_available
  end
  
  it "should inherit from base" do
    @artist.class.ancestors.should include(SpotifyContainer::Base)
  end
end