# -*- encoding : utf-8 -*-

module SpotContainer
  class Clean < Struct.new(:content)
    def process
      string = content.strip
      
      # Song - A + B + C => Song - A
      # Song - A abc/def => Song - A abc
      # Song - A & abc def => Song - A
      # Song - A "abc def" => Song - A
      # Song - A [B + C] => Song - A
      # Song A B.mp3 => Song A B
      # Song a.b.c.d.e => Song a b c d e
      # 10. Song => Song

      [
        /\.[a-z0-9]{2,3}$/, 
        /\[[^\]]*\]/, 
        /".*"/, 
        /'.*'/,
        /[&|\/|\+][^\z]*/, 
        /^(\d+.*?[^a-z]+?)/i
      ].each do |reg|
        string = string.gsub(reg, '').strip
      end
      
      [
        /\(.+?\)/m, 
        /feat(.*?)\s*[^\s]+/i, 
        /[-]+/, 
        /[\s]+/m, 
        /\./, 
        /\_/
      ].each do |reg|
         string = string.gsub(reg, ' ').strip
      end

      ["album version", "remastered"].each do ||
      end
      
      {"ä" => "a", "å" => "a", "ö" => "o"}.each do |from, to|
        string.gsub!(/#{from}/i, to)
      end
      
      string.gsub(/\A\s|\s\z/, '').gsub(/\s+/, ' ').strip.downcase
    rescue Encoding::CompatibilityError
      return string
    end
  end
end