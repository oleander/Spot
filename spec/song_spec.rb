require "spec_helper"
require "lib/spotify/song"

describe SpotifyContainer::Song do
  before(:each) do
    @song = SpotifyContainer::Song.new(JSON.load(File.read("spec/fixtures/track.json"))["tracks"].first)
  end
  
  context "the available? method" do
    it "should contain the AM territory" do
      @song.should be_available("AM")
    end
    
    it "should not contain the RANDOM territory" do
      @song.should_not be_available("RANDOM")
    end
  end
  
  it "should have an artist" do
    @song.artist.should be_instance_of(SpotifyContainer::Artist)
  end
  
  it "should have an album" do
    @song.album.should be_instance_of(SpotifyContainer::Album)
  end
  
  it "should have the correct accessors" do
    @song.length.should be_instance_of(Float)
  end
  
  context "the valid? method" do
    it "should not be valid due to the non existing territory" do
      @song.territory = "RANDOM"
      @song.should_not be_valid
    end
    
    it "should not be valid due to the non existing territory" do
      @song.territory = "AM"
      @song.should be_valid
    end
    
    it "should be valid if no territory if passed" do
      @song.should be_valid
    end
  end
end