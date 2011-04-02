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
    before(:each) do
      @url = stubs("track", "kaizers orchestra")
    end
    
    after(:each) do
      a_request(:get, @url).should have_been_made.once
    end
    
    it "should return the best match" do
      Levenshtein.should_receive(:distance).exactly(100).times.and_return(1)
      Spotify.prime.find_song("kaizers orchestra").result.artist.name.should eq("Kaizers Orchestra")  
    end
  end
  
  context "the cleaner" do
    after(:each) do
      a_request(:get, @url).should have_been_made.once
    end
    
    it "Song - Artist => Song Artist" do
      @url = stubs("track", "this is a string this to")
      Spotify.strip.find_song("this is a string - this to").result
    end
    
    it "Song - A + B + C => Song A" do
      @url = stubs("track", "song a")
      Spotify.strip.find_song("Song - A + B + C").result
    end
    
    it "Song - A abc/def => Song - A abc" do
      @url = stubs("track", "song a abc")
      Spotify.strip.find_song("Song - A abc/def").result
    end
    
    it "Song - A & abc def => Song - A" do
      @url = stubs("track", "song a")
      Spotify.strip.find_song("Song - A & abc def").result
    end
    
    it "Song A \"abc def\" => Song - A" do
      @url = stubs("track", "song a")
      Spotify.strip.find_song("Song A \"abc def\"").result
    end
    
    it "Song - A [B + C] => Song - A" do
      @url = stubs("track", "song a")
      Spotify.strip.find_song("Song - A [B + C]").result
    end
    
    it "Song - A (Super Song) => Song - A" do
      @url = stubs("track", "song a")
      Spotify.strip.find_song("Song - A (Super Song)").result
    end
    
    it "Song A feat. (Super Song) => Song A" do
      @url = stubs("track", "song a")
      Spotify.strip.find_song("Song A feat. (Super Song)").result
    end
    
    it "Song A feat.(Super Song) => Song A" do
      @url = stubs("track", "song a")
      Spotify.strip.find_song("Song A feat. (Super Song)").result
    end
    
    it "Song A feat.Super B C => Song A B C" do
      @url = stubs("track", "song a b c")
      Spotify.strip.find_song("Song A feat.Super B C").result
    end
    
    it "Song A feat Super B C => Song A B C" do
      @url = stubs("track", "song a b c")
      Spotify.strip.find_song("Song A feat Super B C").result
    end
    
    it "A -- B => A B" do
      @url = stubs("track", "a b")
      Spotify.strip.find_song("A -- B").result
    end
    
    it "123 A B => A B" do
      @url = stubs("track", "a b")
      Spotify.strip.find_song("123 A B").result
    end
    
    it "123 A B.mp3 => A B" do
      @url = stubs("track", "a b")
      Spotify.strip.find_song("123 A B.mp3").result
    end
    
    it "01. A B => A B" do
      @url = stubs("track", "a b")
      Spotify.strip.find_song("01. A B").result
    end
    
    it " 01. A B => A B" do
      @url = stubs("track", "a b")
      Spotify.strip.find_song(" 01. A B").result
    end
    
    it "123 A B.mp3(whitespace) => A B" do
      @url = stubs("track", "a b")
      Spotify.strip.find_song("123 A B.mp3 ").result
    end
    
    it "A 1.2.3.4.5 => A 1 2 3 4 5" do
       @url = stubs("track", "a 1 2 3 4 5")
       Spotify.strip.find_song("A 1.2.3.4.5").result
     end
  end
  
  context "method does not exist" do
    before(:each) do
      stubs("track", "string")
    end
    
    it "should raise no method error if the method does't exist (plain value)" do
      lambda { Spotify.find_song("string").random_method }.should raise_error(NoMethodError)
    end
    
    it "should raise an error if the method matches find_*_*" do
      lambda { Spotify.find_song("string").find_by_song }.should raise_error(NoMethodError)
    end
    
    it "should raise an error if the method matches find_all_* " do
      lambda { Spotify.find_song("string").find_all_random }.should raise_error(NoMethodError)
    end
  end
  
  context "exclude" do
    it "should contain a list of non wanted words" do
      @spotify.instance_eval do
        ["tribute", "cover", "remix", "live", "club mix"].each do |value|
          @exclude.include?(value).should == true
        end
      end
    end
    
    it "should have a working exclude? method" do
      {
        "tribute" => true, 
        "random" => false, 
        "cover random" => true, 
        "live" => true, 
        "club mix random" => true, 
        "club random mix" => false,
        "LIVE" => true
      }.each do |comp, outcome|
        @spotify.exclude?(comp).should eq(outcome)
      end
    end
  end
  
  context "territory" do
    before(:each) do
      stubs("track", "search")
    end
    
    it "should not find any songs when using a non valid territory" do
      @spotify.territory("RANDOM").find_all_songs("search").results.should be_empty
    end
    
    it "should find some songs when using a valid territory" do
      @spotify.territory("SE").find_all_songs("search").results.should_not be_empty
    end
    
    it "should be ignored if nil" do
      @spotify.territory(nil).find_all_songs("search").results.count.should eq(@spotify.find_all_songs("search").results.count)
    end
  end
  
  context "the info values" do
    after(:each) do
      a_request(:get, @url).should have_been_made.once
    end
    
    it "should have some info" do
      @url = stubs("track", "kaizers orchestra")      
      spotify = Spotify.strip.find_song("kaizers orchestra")
      spotify.num_results.should eq(188)
      spotify.limit.should eq(100)
      spotify.offset.should eq(0)
      spotify.query.should eq("kaizers orchestra")
    end
  end  
end