require "spec_helper"
require "lib/spotify/base"

describe SpotifyContainer::Base do
  before(:each) do
    @base = SpotifyContainer::Base.new(JSON.load(File.read("spec/fixtures/track.json"))["tracks"].first)
  end
  
  it "should have the correct accessors" do
    @base.name.should_not be_empty
    @base.popularity.should match(/[0-9\.]+/)
    @base.href.should match(/^spotify\:\w+\:[a-zA-Z0-9]+$/)
  end
end