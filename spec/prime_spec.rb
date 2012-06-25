describe Spot::Prime do
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
        "oliver"                           => false,
        "acoustic"                         => true,
        "aacoustic"                        => false
      }.each do |comp, outcome|
        Spot::Prime.ignore?(comp).should eq(outcome)
      end
    end
  end
end