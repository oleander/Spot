# -*- encoding : utf-8 -*-
describe SpotContainer::Clean do
  it "Song - Artist => Song Artist" do
    SpotContainer::Clean.new("this is a string - this to").process.should eq("this is a string this to")
  end
  
  it "Song - A + B + C => Song A" do
    SpotContainer::Clean.new("Song - A + B + C").process.should eq("song a")
  end
  
  it "Song - A abc/def => Song - A abc" do
    SpotContainer::Clean.new("Song - A abc/def").process.should eq("song a abc")
  end
  
  it "Song - A & abc def => Song - A" do
    SpotContainer::Clean.new("Song - A & abc def").process.should eq("song a")
  end
  
  it "Song A \"abc def\" => Song - A" do
    SpotContainer::Clean.new("Song A \"abc def\"").process.should eq("song a")
  end
  
  it "Song - A [B + C] => Song - A" do
    SpotContainer::Clean.new("Song - A [B + C]").process.should eq("song a")
  end
  
  it "Song - A (Super Song) => Song - A" do
    SpotContainer::Clean.new("Song - A (Super Song)").process.should eq("song a")
  end
  
  it "Song A feat. (Super Song) => Song A" do
    SpotContainer::Clean.new("Song A feat. (Super Song)").process.should eq("song a")
  end
  
  it "Song A feat.(Super Song) => Song A" do
    SpotContainer::Clean.new("Song A feat.(Super Song)").process.should eq("song a")
  end
  
  it "Song A feat.Super B C => Song A B C" do
    SpotContainer::Clean.new("Song A feat.Super B C").process.should eq("song a b c")
  end
  
  it "Song A feat Super B C => Song A B C" do
    SpotContainer::Clean.new("Song A feat Super B C").process.should eq("song a b c")
  end
  
  it "A -- B => A B" do
    SpotContainer::Clean.new("A -- B").process.should eq("a b")
  end
  
  it "123 A B => A B" do
    SpotContainer::Clean.new("123 A B").process.should eq("a b")
  end
  
  it "123 A B.mp3 => A B" do
    SpotContainer::Clean.new("123 A B.mp3").process.should eq("a b")
  end
  
  it "01. A B => A B" do
    SpotContainer::Clean.new("01. A B").process.should eq("a b")
  end
  
  it " 01. A B => A B" do
    SpotContainer::Clean.new(" 01. A B").process.should eq("a b")
  end
  
  it "123 A B.mp3(whitespace) => A B" do
    SpotContainer::Clean.new("123 A B.mp3 ").process.should eq("a b")
  end
  
  it "A_B_C_D_E => A B C D E" do
    SpotContainer::Clean.new("A_B_C_D_E").process.should eq("a b c d e")
  end
  
  it "100_A=> A" do
    SpotContainer::Clean.new("100_A").process.should eq("a")
  end
  
  unless RUBY_VERSION =~ /1\.8\.7/
    it "ÅÄÖ åäö å ä ö Å Ä Ö => AAO aao a a o A A O" do
      SpotContainer::Clean.new("ÅÄÖ åäö å ä ö Å Ä Ö").process.should eq("aao aao a a o a a o")
    end
  end
  
  it "don't => don't (no change)" do
    SpotContainer::Clean.new("don't").process.should eq("don't")
  end

  it "A 'don' B => A B" do
    SpotContainer::Clean.new("A 'don' B").process.should eq("a b")
  end

  it "Video Games - Album Version Remastered => Video Games" do
    SpotContainer::Clean.new("Video Games - Album Version Remastered").process.should eq("video games")
  end

  it "r.e.m - Losing My Religion" do
    SpotContainer::Clean.new("r.e.m").process.should eq("r.e.m")
    SpotContainer::Clean.new("r.e.m.").process.should eq("r.e.m.")
  end

  it "Knockin' On Heaven's Door" do
    SpotContainer::Clean.new("Knockin' On Heaven's Door").process.should eq("knockin' on heaven's door")
  end
end