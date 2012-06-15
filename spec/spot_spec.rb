# -*- encoding : utf-8 -*-

describe Spot::Search do
  use_vcr_cassette "spotify"

  before(:each) do
    @spot = Spot::Search.new
  end
  
  context "tracks if success" do
    it "should contain the right amounts of songs" do
      Spot::Search.find_all_songs("kaizers orchestra").should have(100).results
    end
    
    it "should call Spot::Song with the right arguments" do
      Spot::Song.should_receive(:new) do |args|
        args["album"]["released"].should match(/^\d{4}$/)
        args["album"]["href"].should match(/^spotify\:album\:[a-zA-Z0-9]+$/)
        args["album"]["name"].should_not be_empty
        args["album"]["availability"]["territories"].should match(/[A-Z]{2}|(worldwide)/)
        
        args["name"].should_not be_empty
        args["popularity"].should match(/[0-9\.]+/)
        args["length"].should be_instance_of(Float)
        args["href"].should match(/^spotify\:track\:[a-zA-Z0-9]+$/)
        
        validate_artists(args["artists"])
        
        mock_media(true)
      end.exactly(100).times
      
      Spot::Search.find_all_songs("kaizers orchestra").results
    end
      
    it "should not have any songs" do
      Spot::Search.find_all_songs("d41d8cd98f00b204e9800998ecf8427e").results.should be_empty
    end
  end
  
  context "artists if success" do    
    after(:each) do
      a_request(:get, @url).should have_been_made.once
    end
    
    before(:each) do
      @url = generate_url("artist", "kaizers orchestra")
    end  
  
    it "should contain the right amounts of artists" do
      Spot::Search.find_all_artists("kaizers orchestra").results.should have(1).results
    end
    
    it "should call Spot::Artist with the right arguments" do
      Spot::Artist.should_receive(:new) do |args|
        args["name"].should_not be_empty
        args["popularity"].should match(/[0-9\.]+/)
        args["href"].should match(/^spotify\:artist\:[a-zA-Z0-9]+$/)
        mock_media(true)
      end.exactly(1).times
      
      Spot::Search.find_all_artists("kaizers orchestra").results
    end
    
    it "should be able to cache a request" do
      set_up(1, true, Spot::Artist)
      spot = Spot::Search.find_all_artists("kaizers orchestra")
      10.times { spot.results }
    end
    
    it "should not have any songs if nothing is valid" do
      set_up(1, false, Spot::Artist)
      Spot::Search.find_all_artists("kaizers orchestra").results.should be_empty
    end
  end
  
  context "album if success" do  
    it "should contain the right amounts of albums" do
      Spot::Search.find_all_albums("kaizers orchestra").should have(55).results
    end
    
    it "should call Spot::Album with the right arguments" do
      Spot::Album.should_receive(:new) do |args|
        validate_artists(args["artists"])
        
        args["href"].should match(/^spotify\:album\:[a-zA-Z0-9]+$/)
        
        args["availability"]["territories"].should match(/[A-Z]{2}|(worldwide)/)
        args["name"].should_not be_empty
        args["popularity"].should match(/[0-9\.]+/)
        mock_media(true)
      end.exactly(55).times
      
      Spot::Search.find_all_albums("kaizers orchestra").results
    end
    
    it "should be possible to specify a territories" do
      Spot::Search.territory("RANDOM").find_all_albums("kaizers orchestra").results.should be_empty
    end
  end
  
  context "find_*" do    
    it "should only return one element" do
      Spot::Search.find_song("kaizers orchestra").result.should be_instance_of(Spot::Song)
    end
  end
  
  it "should be possible to set a page variable" do
    url = generate_url("track", "kaizers orchestra", 11)
    Spot::Search.page(11).find_song("kaizers orchestra").result
    a_request(:get, url).should have_been_made.once
  end
  
  context "the prime method" do
    it "should return the best match" do
      Spot::Search.prime.find_song("kaizers orchestra").result.artist.name.should eq("Kaizers Orchestra")  
    end
  end
    
  context "method does not exist" do
    it "should raise no method error if the method does't exist (plain value)" do
      lambda { Spot::Search.find_song("string").random_method }.should raise_error(NoMethodError)
    end
    
    it "should raise an error if the method matches find_*_*" do
      lambda { Spot::Search.find_song("string").find_by_song }.should raise_error(NoMethodError)
    end
    
    it "should raise an error if the method matches find_all_* " do
      lambda { Spot::Search.find_song("string").find_all_random }.should raise_error(NoMethodError)
    end
  end
  
  context "exclude" do    
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
        "random"                           => false,
        "oliver"                           => false
      }.each do |comp, outcome|
        @spot.exclude?(comp).should eq(outcome)
      end
    end
  end
  
  context "territory" do
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
    
  context "the info values" do
    after(:each) do
      a_request(:get, @url).should have_been_made.once
    end
    
    it "should have some info" do
      @url = generate_url("track", "kaizers orchestra")
      spot = Spot::Search.strip.find_song("kaizers orchestra")
      spot.num_results.should be > 0
      spot.limit.should eq(100)
      spot.offset.should eq(0)
      spot.query.should eq("kaizers orchestra")
    end
  end

  context "bugs" do
    it "handles 'Jason Derulo - Undefeated'" do
      Spot::Search.strip.find_song("Jason Derulo - Undefeated").result.to_s.should eq("Jason Derulo - Undefeated")
    end

    it "handles 'Call My Name - Tove Styrke'" do
      Spot::Search.territory("SE").prime.strip.find_song("Tove Styrke - Call My Name").result.to_s.should eq("Tove Styrke - Call My Name")
    end

    it "handles 'D'Banj - Oliver Twist'" do
      Spot::Search.territory("SE").prime.strip.find_song("D'Banj - Oliver Twist").result.to_s.downcase.should eq("D'Banj - Oliver Twist".downcase)
    end
  end
end