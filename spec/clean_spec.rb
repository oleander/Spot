# -*- encoding : utf-8 -*-
describe Spot::Clean do
  it "Song - Artist => Song Artist" do
    Spot::Clean.new("this is a string - this to").process.should eq("this is a string this to")
  end
  
  it "Song - A + B + C => Song A" do
    Spot::Clean.new("Song - A + B + C").process.should eq("song a")
  end
  
  it "Song - A abc/def => Song - A abc" do
    Spot::Clean.new("Song - A abc/def").process.should eq("song a abc")
  end
  
  it "Song - A & abc def => Song - A" do
    Spot::Clean.new("Song - A & abc def").process.should eq("song a")
  end
  
  it "Song A \"abc def\" => Song - A" do
    Spot::Clean.new("Song A \"abc def\"").process.should eq("song a")
  end
  
  it "Song - A [B + C] => Song - A" do
    Spot::Clean.new("Song - A [B + C]").process.should eq("song a")
  end
  
  it "Song - A (Super Song) => Song - A" do
    Spot::Clean.new("Song - A (Super Song)").process.should eq("song a")
  end
  
  it "Song A feat. (Super Song) => Song A" do
    Spot::Clean.new("Song A feat. (Super Song)").process.should eq("song a")
  end
  
  it "Song A feat.(Super Song) => Song A" do
    Spot::Clean.new("Song A feat.(Super Song)").process.should eq("song a")
  end
  
  it "Song A feat.Super B C => Song A B C" do
    Spot::Clean.new("Song A feat.Super B C").process.should eq("song a b c")
  end
  
  it "Song A feat Super B C => Song A B C" do
    Spot::Clean.new("Song A feat Super B C").process.should eq("song a b c")
  end
  
  it "A -- B => A B" do
    Spot::Clean.new("A -- B").process.should eq("a b")
  end
  
  it "123 A B => A B" do
    Spot::Clean.new("123 A B").process.should eq("a b")
  end
  
  it "123 A B.mp3 => A B" do
    Spot::Clean.new("123 A B.mp3").process.should eq("a b")
  end
  
  it "01. A B => A B" do
    Spot::Clean.new("01. A B").process.should eq("a b")
  end
  
  it " 01. A B => A B" do
    Spot::Clean.new(" 01. A B").process.should eq("a b")
  end
  
  it "123 A B.mp3(whitespace) => A B" do
    Spot::Clean.new("123 A B.mp3 ").process.should eq("a b")
  end
  
  it "A_B_C_D_E => A B C D E" do
    Spot::Clean.new("A_B_C_D_E").process.should eq("a b c d e")
  end
  
  it "100_A=> A" do
    Spot::Clean.new("100_A").process.should eq("a")
  end
  
  unless RUBY_VERSION =~ /1\.8\.7/
    it "ÅÄÖ åäö å ä ö Å Ä Ö => AAO aao a a o A A O" do
      Spot::Clean.new("ÅÄÖ åäö å ä ö Å Ä Ö").process.should eq("aao aao a a o a a o")
    end
  end
  
  it "don't => don't (no change)" do
    Spot::Clean.new("don't").process.should eq("don't")
  end

  it "A 'don' B => A B" do
    Spot::Clean.new("A 'don' B").process.should eq("a b")
  end

  it "Video Games - Album Version Remastered => Video Games" do
    Spot::Clean.new("Video Games - Album Version Remastered").process.should eq("video games")
  end

  it "r.e.m - Losing My Religion" do
    Spot::Clean.new("r.e.m").process.should eq("r.e.m")
    Spot::Clean.new("r.e.m.").process.should eq("r.e.m.")
  end

  it "Knockin' On Heaven's Door" do
    Spot::Clean.new("Knockin' On Heaven's Door").process.should eq("knockin' on heaven's door")
  end

  it "Jason Derulo - Undefeated" do
    Spot::Clean.new("Undefeated").process.should eq("undefeated")
  end

  it "Da Bop - Video Edit" do
    Spot::Clean.new("Da Bop - Video Edit").process.should eq("da bop")
  end
end