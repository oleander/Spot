require "rspec"
require "spot"
require "vcr"
require "webmock/rspec"

RSpec.configure do |config|
  config.mock_with :rspec
  config.extend VCR::RSpec::Macros
end

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  c.hook_into :webmock
  c.default_cassette_options = {
    record: :all
  }
  c.allow_http_connections_when_no_cassette = false
end

def mock_media(ret)
  song = mock(Object.new)
  song.should_receive(:valid?).any_number_of_times.and_return(ret)
  song
end

def validate_artists(artists)
  artists.each do |artist|
    artist["name"].should_not be_empty
    artist["href"].to_s.should match(/^spotify\:artist\:[a-zA-Z0-9]+|.{0}$/) # Can be blank
  end
end

def set_up(times = 100, ret = true, klass = SpotContainer::Song)
  klass.should_receive(:new).exactly(times).times.and_return(mock_media(ret))
end

def generate_url(type, search, page = 1)
  "http://ws.spotify.com/search/1/#{type}.json?q=#{URI.escape(search)}&page=#{page}"
end

def stubs(type, search, page = 1)
  # url = generate_url(type, search, page)
  # stub_request(:get, url).
  #   to_return(:body => File.read("spec/fixtures/#{type}.json"), :status => 200)
  # url
end