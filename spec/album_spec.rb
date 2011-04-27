require "spec_helper"
require "./lib/spotify/album"

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
  
  context "the available? method" do
    it "should contain the AG territory" do
      @album.should be_available("AG")
    end
    
    it "should not contain the RANDOM territory" do
      @album.should_not be_available("RANDOM")
    end
  end
  
  it "should have a working to string method" do
    @album.to_s.should eq(@album.name)
  end
end