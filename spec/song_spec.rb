require "spec_helper"
require "./lib/spot/song"

describe SpotContainer::Song do
  before(:each) do
    @song = SpotContainer::Song.new(JSON.load(File.read("spec/fixtures/track.json"))["tracks"].first)
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
    @song.artist.should be_instance_of(SpotContainer::Artist)
  end
  
  it "should have an album" do
    @song.album.should be_instance_of(SpotContainer::Album)
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
  
  it "should inherit from base" do
    @song.class.ancestors.should include(SpotContainer::Base)
  end
  
  it "should have a title method that equals the name method" do
    @song.title.should eq(@song.name)
  end
  
  it "should have a working to string method" do
    @song.to_s.should eq("#{@song.title} - #{@song.artist.name}")
  end
  
  context "user requst" do
    before(:all) do
      WebMock.allow_net_connect!
    end
    
    it "should match user request" do
      Spot.territory("SE").prime.strip.find_song("Call My Name - Tove Styrke").result.to_s.should eq("Call My Name - Tove Styrke")
    end
  end
end