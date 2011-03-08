require "json/pure"
require "rest-client"
require "lib/spotify/song.rb"

class Spotify
  
  def songs
    @songs ||= send(@type.to_sym)
  end
  
  def url(type, url)
    @url, @type = url, type; 
  end
  
  private
    def tracks
      songs = []; content["tracks"].each do |track|
        song = SpotifyContainer::Song.new(track)
        songs << song if song.valid?
      end; songs      
    end
    
    def content
      @content ||= JSON.parse(download)
    end
    
    def download
      @download ||= RestClient.get @url, :timeout => 10
    end
end
