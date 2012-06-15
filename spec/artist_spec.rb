require "spec_helper"
require "./lib/spot/artist"

describe Spot::Artist do
  before(:each) do
    @artist = Spot::Artist.new(JSON.load(File.read("spec/fixtures/artist.json"))["artists"].first)
  end
  
  it "should always be valid" do
    @artist.should be_valid
  end
  
  it "should inherit from base" do
    @artist.class.ancestors.should include(Spot::Base)
  end
  
  it "should have a working to string method" do
    @artist.to_s.should eq(@artist.name)
  end
end