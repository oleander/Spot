describe Spotify do  
  before(:all) do
    @tracks_url = "http://ws.spotify.com/search/1/track.json?q=kaizers+orchestra"
  end
  
  before(:each) do
    @spotify = Spotify.new
  end
  
  context "tracks" do    
    before(:each) do
      @spotify.url(:tracks, @tracks_url)
      stub_request(:get, @tracks_url).to_return(:body => File.read("spec/fixtures/track.json"), :status => 200)
    end
    
    after(:each) do
      a_request(:get, @tracks_url).should have_been_made.once
    end
    
    it "should contain the right amounts of songs" do
      set_up(100, true)
      @spotify.should have(100).songs
    end
    
    it "should call SpotifyContainer::Song with the right arguments" do
      SpotifyContainer::Song.should_receive(:new) do |args|
        args["name"].should_not be_empty
        args["popularity"].should match(/[0-9\.]+/)
        args["album"]["availability"]["territories"].should match(/[A-Z]{2}/)
        args["length"].should be_instance_of(Float)
        args["href"].should match(/^spotify\:track\:[a-zA-Z0-9]+$/)
        args["artists"].should be_instance_of(Array)
        mock_song(true)
      end.exactly(100).times
      
      @spotify.songs
    end
    
    it "should be able to cache a request" do
      set_up(100, true)
      10.times { @spotify.songs }
    end
    
    it "should not have any songs if nothing is valid" do
      set_up(100, false)
      @spotify.songs.should be_empty
    end
  end
  
  def mock_song(ret)
    song = mock(Object.new)
    song.should_receive(:valid?).any_number_of_times.and_return(ret)
    song
  end
  
  def set_up(times = 100, ret = true)
    SpotifyContainer::Song.should_receive(:new).exactly(times).times.and_return(mock_song(ret))
  end
end