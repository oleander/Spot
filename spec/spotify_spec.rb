describe Spotify do
  before(:each) do
    @spotify = Spotify.new
  end
  
  context "tracks if success" do    
    before(:each) do
      @tracks_url = "http://ws.spotify.com/search/1/track.json?q=kaizers+orchestra"
      @spotify.url = @tracks_url
      stub_request(:get, @tracks_url).to_return(:body => File.read("spec/fixtures/track.json"), :status => 200)
    end
    
    after(:each) do
      a_request(:get, @tracks_url).should have_been_made.once
    end
    
    it "should contain the right amounts of songs" do
      set_up(100, true)
      @spotify.songs.count.should eq(100)
    end
    
    it "should call SpotifyContainer::Song with the right arguments" do
      SpotifyContainer::Song.should_receive(:new) do |args|
        args["album"]["released"].should match(/^\d{4}$/)
        args["album"]["href"].should match(/^spotify\:album\:[a-zA-Z0-9]+$/)
        args["album"]["name"].should_not be_empty
        args["album"]["availability"]["territories"].should match(/[A-Z]{2}/)
        
        args["name"].should_not be_empty
        args["popularity"].should match(/[0-9\.]+/)
        args["length"].should be_instance_of(Float)
        args["href"].should match(/^spotify\:track\:[a-zA-Z0-9]+$/)
        
        validate_artists(args["artists"])
        
        mock_media(true)
      end.exactly(100).times
      
      @spotify.songs
    end
    
    it "should be able to cache a request" do
      set_up(100, true)
      10.times { @spotify.songs }
    end
    
    it "should not have any songs if nothing is valid" do
      set_up(100, false)
      @spotify.songs.count.should eq(0)
    end
  end
  
  context "artists if success" do
    before(:each) do
      @artists_url = "http://ws.spotify.com/search/1/artist.json?q=foo"
      @spotify.url = @artists_url
      stub_request(:get, @artists_url).to_return(:body => File.read("spec/fixtures/artist.json"), :status => 200)
    end
    
    after(:each) do
      a_request(:get, @artists_url).should have_been_made.once
    end
    
    it "should contain the right amounts of artists" do
      @spotify.artists.count.should eq(100)
    end
    
    it "should call SpotifyContainer::Artist with the right arguments" do
      SpotifyContainer::Artist.should_receive(:new) do |args|
        args["name"].should_not be_empty
        args["popularity"].should match(/[0-9\.]+/)
        args["href"].should match(/^spotify\:artist\:[a-zA-Z0-9]+$/)
        mock_media(true)
      end.exactly(100).times
      
      @spotify.artists
    end
    
    it "should be able to cache a request" do
      set_up(100, true, SpotifyContainer::Artist)
      10.times { @spotify.artists }
    end
    
    it "should not have any songs if nothing is valid" do
      set_up(100, false, SpotifyContainer::Artist)
      @spotify.artists.count.should eq(0)
    end
  end
  
  context "album if success" do
    before(:each) do
      @albums_url = "http://ws.spotify.com/search/1/album.json?q=a"
      @spotify.url = @albums_url
      stub_request(:get, @albums_url).to_return(:body => File.read("spec/fixtures/album.json"), :status => 200)
    end
    
    after(:each) do
      a_request(:get, @albums_url).should have_been_made.once
    end
    
    it "should contain the right amounts of albums" do
      @spotify.albums.count.should eq(100)
    end
    
    it "should call SpotifyContainer::Artist with the right arguments" do
      SpotifyContainer::Album.should_receive(:new) do |args|
        validate_artists(args["artists"])
        
        args["href"].should match(/^spotify\:album\:[a-zA-Z0-9]+$/)
        
        args["availability"]["territories"].should match(/[A-Z]{2}/)
        args["name"].should_not be_empty
        args["popularity"].should match(/[0-9\.]+/)
        mock_media(true)
      end.exactly(100).times
      
      @spotify.albums
    end
    
    it "should be able to cache a request" do
      set_up(100, true, SpotifyContainer::Album)
      10.times { @spotify.albums }
    end
    
    it "should not have any songs if nothing is valid" do
      set_up(100, false, SpotifyContainer::Album)
      @spotify.albums.count.should eq(0)
    end
  end
  
  context "error" do
    it "should be able to handle 403 - The rate limiting has kicked in" do
      albums_url = "http://ws.spotify.com/search/1/album.json?q=a"
      @spotify.url = albums_url
      spec_error(albums_url, 403)
      lambda { @spotify.albums }.should raise_error(SpotifyContainer::RequestLimitError)
    end
    
    def spec_error(url, code)
      stub_request(:get, url).to_return(:body => "", :status => code)
    end
  end
  
  def mock_media(ret)
    song = mock(Object.new)
    song.should_receive(:valid?).any_number_of_times.and_return(ret)
    song
  end
  
  def validate_artists(artists)
    artists.each do |artist|
      artist["name"].should_not be_empty
      artist["href"].to_s.should match(/^spotify\:artist\:[a-zA-Z0-9]+|.{0}$/) # Can be blank
    end
  end
  
  def set_up(times = 100, ret = true, klass = SpotifyContainer::Song)
    klass.should_receive(:new).exactly(times).times.and_return(mock_media(ret))
  end
end