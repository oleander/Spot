require "spec_helper"
require "lib/spotify/artist"

describe SpotifyContainer::Artist do
  before(:each) do
    @artist = SpotifyContainer::Artist.new(JSON.load(File.read("spec/fixtures/artist.json"))["artists"].first)
  end
  
  it "should always be valid" do
    @artist.should be_valid
  end
  
  it "should inherit from base" do
    @artist.class.ancestors.should include(SpotifyContainer::Base)
  end
  
  it "should have a working to string method" do
    @artist.to_s.should eq(@artist.name)
  end
end