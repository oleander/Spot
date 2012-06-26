# -*- encoding : utf-8 -*-

module Spot
  class Clean
    attr_reader :content
    def initialize(content)
      @content = content
      @exclude = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__)), "exclude.yml"))
    end

    def process
      string = content.strip

      @exclude.each do |exclude|
        string = string.gsub(/#{exclude}/i, "")
      end

      # Song - A + B + C => Song - A
      # Song - A abc/def => Song - A abc
      # Song - A & abc def => Song - A
      # Song - A "abc def" => Song - A
      # Song - A [B + C] => Song - A
      # Song A B.mp3 => Song A B
      # 10. Song => Song
      [
        /\.[a-z0-9]{2,3}$/, 
        /\[[^\]]*\]/, 
        /".*"/,  
        /(\s+|^)'.*'(\s+|$)/,
        /[&|\/|\+][^\z]*/, 
        /^(\d+.*?[^a-z]+?)/i
      ].each do |reg|
        string = string.gsub(reg, ' ').strip
      end
      
      [
        /\(.+?\)/m, 
        /[^a-z0-9]feat(.*?)\s*[^\s]+/i, 
        /[-]+/, 
        /[\s]+/m, 
        /\_/
      ].each do |reg|
         string = string.gsub(reg, ' ').strip
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