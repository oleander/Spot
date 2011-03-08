require "json/pure"
require "rest-client"
require "lib/spotify/song"
require "lib/spotify/artist"

class Spotify
  attr_writer :url
  
  def songs
    return @songs if @songs

    @songs = []; content["tracks"].each do |song|
      song = SpotifyContainer::Song.new(song)      
      @songs << song if song.valid?
    end
    
    @songs
  end
  
  def artists
    return @artists if @artists

    @artists = []; content["artists"].each do |artist|
      artist = SpotifyContainer::Artist.new(artist)      
      @artists << artist if artist.valid?
    end
    
    @artists
  end
  
  private
    
    def content
      @content ||= JSON.parse(download)
    end
    
    def download
      @download ||= RestClient.get @url, :timeout => 10
    end
end
