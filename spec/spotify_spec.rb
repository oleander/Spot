# -*- encoding : utf-8 -*-

describe Spot do
  before(:each) do
    @spot = Spot.new
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
      Spot.find_all_songs("kaizers orchestra").should have(100).results
    end
    
    it "should call SpotContainer::Song with the right arguments" do
      SpotContainer::Song.should_receive(:new) do |args|
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
      
      Spot.find_all_songs("kaizers orchestra").results
    end
    
    it "should be able to cache a request" do
      set_up(100, true)
      spot = Spot.find_all_songs("kaizers orchestra")
      10.times { spot.results }
    end
  
    it "should not have any songs if nothing is valid" do
      set_up(100, false)
      Spot.find_all_songs("kaizers orchestra").results.should be_empty
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
      set_up(100, true, SpotContainer::Artist)
      Spot.find_all_artists("kaizers orchestra").should have(100).results
    end
    
    it "should call SpotContainer::Artist with the right arguments" do
      SpotContainer::Artist.should_receive(:new) do |args|
        args["name"].should_not be_empty
        args["popularity"].should match(/[0-9\.]+/)
        args["href"].should match(/^spotify\:artist\:[a-zA-Z0-9]+$/)
        mock_media(true)
      end.exactly(100).times
      
      Spot.find_all_artists("kaizers orchestra").results
    end
    
    it "should be able to cache a request" do
      set_up(100, true, SpotContainer::Artist)
      spot = Spot.find_all_artists("kaizers orchestra")
      10.times { spot.results }
    end
    
    it "should not have any songs if nothing is valid" do
      set_up(100, false, SpotContainer::Artist)
      Spot.find_all_artists("kaizers orchestra").results.should be_empty
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
      set_up(100, true, SpotContainer::Album)
      Spot.find_all_albums("kaizers orchestra").should have(100).results
    end
    
    it "should call SpotContainer::Album with the right arguments" do
      SpotContainer::Album.should_receive(:new) do |args|
        validate_artists(args["artists"])
        
        args["href"].should match(/^spotify\:album\:[a-zA-Z0-9]+$/)
        
        args["availability"]["territories"].should match(/[A-Z]{2}/)
        args["name"].should_not be_empty
        args["popularity"].should match(/[0-9\.]+/)
        mock_media(true)
      end.exactly(100).times
      
      Spot.find_all_albums("kaizers orchestra").results
    end
    
    it "should be possible to specify a territories" do
      Spot.territory("RANDOM").find_all_albums("kaizers orchestra").results.should be_empty
    end
    
    it "should be able to cache a request" do
      set_up(100, true, SpotContainer::Album)
      spot = Spot.find_all_albums("kaizers orchestra")
      10.times { spot.results }
    end
    
    it "should not have any songs if nothing is valid" do
      set_up(100, false, SpotContainer::Album)
      Spot.find_all_albums("kaizers orchestra").results.should be_empty
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
      Spot.find_song("kaizers orchestra").result.should be_instance_of(SpotContainer::Song)
    end
  end
  
  it "should be possible to set a page variable" do
    url = stubs("track", "kaizers orchestra", 11)
    Spot.page(11).find_song("kaizers orchestra").result.should be_instance_of(SpotContainer::Song)
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
      Spot.prime.find_song("kaizers orchestra").result.artist.name.should eq("Kaizers Orchestra")  
    end
  end
  
  context "the cleaner" do
    after(:each) do
      a_request(:get, @url).should have_been_made.once
    end
    
    it "Song - Artist => Song Artist" do
      @url = stubs("track", "this is a string this to")
      Spot.strip.find_song("this is a string - this to").result
    end
    
    it "Song - A + B + C => Song A" do
      @url = stubs("track", "song a")
      Spot.strip.find_song("Song - A + B + C").result
    end
    
    it "Song - A abc/def => Song - A abc" do
      @url = stubs("track", "song a abc")
      Spot.strip.find_song("Song - A abc/def").result
    end
    
    it "Song - A & abc def => Song - A" do
      @url = stubs("track", "song a")
      Spot.strip.find_song("Song - A & abc def").result
    end
    
    it "Song A \"abc def\" => Song - A" do
      @url = stubs("track", "song a")
      Spot.strip.find_song("Song A \"abc def\"").result
    end
    
    it "Song - A [B + C] => Song - A" do
      @url = stubs("track", "song a")
      Spot.strip.find_song("Song - A [B + C]").result
    end
    
    it "Song - A (Super Song) => Song - A" do
      @url = stubs("track", "song a")
      Spot.strip.find_song("Song - A (Super Song)").result
    end
    
    it "Song A feat. (Super Song) => Song A" do
      @url = stubs("track", "song a")
      Spot.strip.find_song("Song A feat. (Super Song)").result
    end
    
    it "Song A feat.(Super Song) => Song A" do
      @url = stubs("track", "song a")
      Spot.strip.find_song("Song A feat. (Super Song)").result
    end
    
    it "Song A feat.Super B C => Song A B C" do
      @url = stubs("track", "song a b c")
      Spot.strip.find_song("Song A feat.Super B C").result
    end
    
    it "Song A feat Super B C => Song A B C" do
      @url = stubs("track", "song a b c")
      Spot.strip.find_song("Song A feat Super B C").result
    end
    
    it "A -- B => A B" do
      @url = stubs("track", "a b")
      Spot.strip.find_song("A -- B").result
    end
    
    it "123 A B => A B" do
      @url = stubs("track", "a b")
      Spot.strip.find_song("123 A B").result
    end
    
    it "123 A B.mp3 => A B" do
      @url = stubs("track", "a b")
      Spot.strip.find_song("123 A B.mp3").result
    end
    
    it "01. A B => A B" do
      @url = stubs("track", "a b")
      Spot.strip.find_song("01. A B").result
    end
    
    it " 01. A B => A B" do
      @url = stubs("track", "a b")
      Spot.strip.find_song(" 01. A B").result
    end
    
    it "123 A B.mp3(whitespace) => A B" do
      @url = stubs("track", "a b")
      Spot.strip.find_song("123 A B.mp3 ").result
    end
    
    it "A_B_C_D_E => A B C D E" do
      @url = stubs("track", "a b c d e")
      Spot.strip.find_song("A_B_C_D_E").result
    end
    
    it "100_A=> A" do
      @url = stubs("track", "a")
      Spot.strip.find_song("100_A").result
    end
    
    it "A 1.2.3.4.5 => A 1 2 3 4 5" do
      @url = stubs("track", "a 1 2 3 4 5")
      Spot.strip.find_song("A 1.2.3.4.5").result
    end
    
    unless RUBY_VERSION =~ /1\.8\.7/
      it "ÅÄÖ åäö å ä ö Å Ä Ö => AAO aao a a o A A O" do
        @url = stubs("track", "aao aao a a o a a o")
        Spot.strip.find_song("ÅÄÖ åäö å ä ö Å Ä Ö").result
      end
    end
    
    it "don't => don't (no change)" do
      @url = stubs("track", "don't")
      Spot.strip.find_song("don't").result
    end
    
    it "A 'don' B => A B" do
      @url = stubs("track", "a b")
      Spot.strip.find_song("A 'don' B").result
    end
  end
  
  context "method does not exist" do
    before(:each) do
      stubs("track", "string")
    end
    
    it "should raise no method error if the method does't exist (plain value)" do
      lambda { Spot.find_song("string").random_method }.should raise_error(NoMethodError)
    end
    
    it "should raise an error if the method matches find_*_*" do
      lambda { Spot.find_song("string").find_by_song }.should raise_error(NoMethodError)
    end
    
    it "should raise an error if the method matches find_all_* " do
      lambda { Spot.find_song("string").find_all_random }.should raise_error(NoMethodError)
    end
  end
  
  context "exclude" do
    it "should contain a list of non wanted words" do
      @spot.instance_eval do
        [
          "tribute", 
          "cover", 
          "remix", 
          "live", 
          "club mix", 
          "karaoke", 
          "club version",
          "remaster",
          "demo",
          "made famous by",
          "remixes",
          "instrumental(s)?",
           "ringtone(s)?"
        ].each do |value|
          @exclude.include?(value).should == true
        end
      end
    end
    
    it "should have a working exclude? method" do
      {
        "tribute"                          => true,
        "cover random"                     => true, 
        "live"                             => true,
        "club mix random"                  => true,
        "LIVE"                             => true,
        "karaoKE"                          => true,
        "instrumental"                     => true,
        "Karaoke - Won't Get Fooled Again" => true,
        "club version"                     => true,
        "instrumentals"                    => true,
        "demo"                             => true,
        "made famous by"                   => true,
        "remixes"                          => true,
        "ringtone"                         => true,
        "ringtones"                        => true,
        "riingtonerandom"                  => false,
        "club random mix"                  => false,
        "random"                           => false
      }.each do |comp, outcome|
        @spot.exclude?(comp).should eq(outcome)
      end
    end
  end
  
  context "territory" do
    before(:each) do
      stubs("track", "search")
    end
    
    it "should not find any songs when using a non valid territory" do
      @spot.territory("RANDOM").find_all_songs("search").results.should be_empty
    end
    
    it "should find some songs when using a valid territory" do
      @spot.territory("SE").find_all_songs("search").results.should_not be_empty
    end
    
    it "should be ignored if nil" do
      @spot.territory(nil).find_all_songs("search").results.count.should eq(@spot.find_all_songs("search").results.count)
    end
  end
  
  context "bugs" do
    before(:each) do
      stub_request(:get, "http://ws.spotify.com/search/1/track.json?page=1&q=the%20rolling%20stones%20itn%20roll").
        to_return(:body => File.read("spec/fixtures/track.json"), :status => 200)
    end
    
    it "should not raise an error" do
      lambda { Spot.prime.strip.find_song("013 - The Rolling Stones - It's Only Rock 'N Roll.mp3").result }.should_not raise_error
    end
  end
  
  context "tribute" do
    before(:each) do
      stub_request(:get, "http://ws.spotify.com/search/1/track.json?page=1&q=britney%20spears%20tribute").
        to_return(:body => File.read("spec/fixtures/exclude.tribute.json"), :status => 200)
    end
    
    it "should not return anything" do
      Spot.prime.strip.find_song("Britney Spears Tribute").result.should be_nil
    end
  end
  
  context "prefix" do    
    it "should be possible to add a prefix - without strip" do
      @url = stubs("track", "-A B C C")
      @spot.prefix("-A B C").find_song("C").result
    end
    
    it "should be possible to add a prefix - with strip" do
      @url = stubs("track", "a b c c")
      @spot.strip.prefix("-A B C").find_song("C").result
    end
    
    it "should be possible to add a prefix, 123 A B.mp3=> A B" do
      @url = stubs("track", "random a b")
      @spot.strip.prefix("random").find_song("123 A B.mp3 ").result
    end
    
    after(:each) do
      a_request(:get, @url).should have_been_made.once
    end
  end
  
  context "the info values" do
    after(:each) do
      a_request(:get, @url).should have_been_made.once
    end
    
    it "should have some info" do
      @url = stubs("track", "kaizers orchestra")      
      spot = Spot.strip.find_song("kaizers orchestra")
      spot.num_results.should eq(188)
      spot.limit.should eq(100)
      spot.offset.should eq(0)
      spot.query.should eq("kaizers orchestra")
    end
  end
end