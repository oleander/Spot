require "spec_helper"
require "./lib/spotify/base"

describe SpotifyContainer::Base do
  before(:each) do
    @base = SpotifyContainer::Base.new(JSON.load(File.read("spec/fixtures/track.json"))["tracks"].first)
  end
  
  it "should have the correct accessors" do
    @base.name.should_not be_empty
    @base.popularity.should eq(0.79999)
    @base.href.should match(/^spotify\:\w+\:[a-zA-Z0-9]+$/)
  end
  
  context "the url methods" do
    it "should have a default type" do
      @base.href.should eq("spotify:track:7lqGgwrEhURX4k5IB8A80S")
    end
    
    it "should be possible to define a url href" do
      @base.href("spotify").should eq("spotify:track:7lqGgwrEhURX4k5IB8A80S")
    end
    
    it "should be possible to define a http href" do
      @base.href("http").should eq("http://open.spotify.com/track/7lqGgwrEhURX4k5IB8A80S")
    end
    
    it "should return nil if no URL if found" do
      @base.should_receive(:href_spotify).exactly(3).times.and_return(nil)
      @base.href("spotify").should be_nil
      @base.href("http").should be_nil
      @base.href.should be_nil
    end
  end
end