require "spec_helper"
require "lib/spotify/album"

describe SpotifyContainer::Album do
  before(:each) do
    @album = SpotifyContainer::Album.new(JSON.load(File.read("spec/fixtures/album.json"))["albums"].first)
  end
  
  it "should have an artist" do
    @album.artist.should be_instance_of(SpotifyContainer::Artist)
  end
  
  it "should inherit from base" do
    @album.class.ancestors.should include(SpotifyContainer::Base)
  end
end