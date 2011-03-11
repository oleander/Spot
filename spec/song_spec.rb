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
  
end