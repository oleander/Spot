describe Spotify do
  before(:each) do
    @spotify = Spotify.new
  end
  
  context "tracks if success" do
    after(:each) do
      a_request(:get, @url).should have_been_made.once
    end
    
    before(:each) do
      @url = stubs("track", "kaizers orchestra")
    end
    
    it "should contain the right amounts of songs" do
      set_up(100, true)
      Spotify.find_all_songs("kaizers orchestra").should have(100).results
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
      
      Spotify.find_all_songs("kaizers orchestra").results
    end
    
    it "should be able to cache a request" do
      set_up(100, true)
      spotify = Spotify.find_all_songs("kaizers orchestra")
      10.times { spotify.results }
    end
  
    it "should not have any songs if nothing is valid" do
      set_up(100, false)
      Spotify.find_all_songs("kaizers orchestra").results.should be_empty
    end
  end
  
  context "artists if success" do    
    after(:each) do
      a_request(:get, @url).should have_been_made.once
    end
    
    before(:each) do
      @url = stubs("artist", "kaizers orchestra")
    end  
  
    it "should contain the right amounts of artists" do
      set_up(100, true, SpotifyContainer::Artist)
      Spotify.find_all_artists("kaizers orchestra").should have(100).results
    end
    
    it "should call SpotifyContainer::Artist with the right arguments" do
      SpotifyContainer::Artist.should_receive(:new) do |args|
        args["name"].should_not be_empty
        args["popularity"].should match(/[0-9\.]+/)
        args["href"].should match(/^spotify\:artist\:[a-zA-Z0-9]+$/)
        mock_media(true)
      end.exactly(100).times
      
      Spotify.find_all_artists("kaizers orchestra").results
    end
    
    it "should be able to cache a request" do
      set_up(100, true, SpotifyContainer::Artist)
      spotify = Spotify.find_all_artists("kaizers orchestra")
      10.times { spotify.results }
    end
    
    it "should not have any songs if nothing is valid" do
      set_up(100, false, SpotifyContainer::Artist)
      Spotify.find_all_artists("kaizers orchestra").results.should be_empty
    end
  end
  
  context "album if success" do    
    after(:each) do
      a_request(:get, @url).should have_been_made.once
    end
    
    before(:each) do
      @url = stubs("album", "kaizers orchestra")
    end  
  
    it "should contain the right amounts of albums" do
      set_up(100, true, SpotifyContainer::Album)
      Spotify.find_all_albums("kaizers orchestra").should have(100).results
    end
    
    it "should call SpotifyContainer::Album with the right arguments" do
      SpotifyContainer::Album.should_receive(:new) do |args|
        validate_artists(args["artists"])
        
        args["href"].should match(/^spotify\:album\:[a-zA-Z0-9]+$/)
        
        args["availability"]["territories"].should match(/[A-Z]{2}/)
        args["name"].should_not be_empty
        args["popularity"].should match(/[0-9\.]+/)
        mock_media(true)
      end.exactly(100).times
      
      Spotify.find_all_albums("kaizers orchestra").results
    end
    
    it "should be able to cache a request" do
      set_up(100, true, SpotifyContainer::Album)
      spotify = Spotify.find_all_albums("kaizers orchestra")
      10.times { spotify.results }
    end
    
    it "should not have any songs if nothing is valid" do
      set_up(100, false, SpotifyContainer::Album)
      Spotify.find_all_albums("kaizers orchestra").results.should be_empty
    end
  end
    
  context "error" do
    it "should be able to handle 403 - The rate limiting has kicked in" do
      url = stubs("album", "kaizers orchestra")
      spec_error(url, 403)
      lambda { Spotify.find_all_albums("kaizers orchestra").results }.should raise_error(SpotifyContainer::RequestLimitError)
    end
    
    def spec_error(url, code)
      stub_request(:get, url).to_return(:body => File.read("spec/fixtures/album.json"), :status => code)
    end
  end
  
  context "find_*" do
    after(:each) do
      a_request(:get, @url).should have_been_made.once
    end
    
    before(:each) do
      @url = stubs("track", "kaizers orchestra")
    end
    
    it "should only return one element" do
      Spotify.find_song("kaizers orchestra").result.should be_instance_of(SpotifyContainer::Song)
    end
  end
  
  it "should be possible to set a page variable" do
    url = stubs("track", "kaizers orchestra", 11)
    Spotify.page(11).find_song("kaizers orchestra").result.should be_instance_of(SpotifyContainer::Song)
    a_request(:get, url).should have_been_made.once
  end
  
  context "the prime method" do
    it "should return the best match" do
      url = stubs("track", "kaizers orchestra")
      Spotify.prime.find_song("kaizers orchestra").result.artist.name.should match(/kaizers orchestra/i)
      a_request(:get, url).should have_been_made.once
    end
  end
  
  it "should be possible to clean ingoing argument and use it in a search"
  it "should raise an error if the given method doesn't exist"
  
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
  
  def generate_url(type, search, page = 1)
    "http://ws.spotify.com/search/1/#{type}.json?q=#{URI.escape(search)}&page=#{page}"
  end
  
  def stubs(type, search, page = 1)
    url = generate_url(type, search, page)
    stub_request(:get, url).
      to_return(:body => File.read("spec/fixtures/#{type}.json"), :status => 200)
    url
  end
end