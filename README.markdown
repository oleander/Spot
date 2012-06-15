# Spot

A Ruby implementation of the [Spotify Meta API](http://developer.spotify.com/en/metadata-api/overview/).

This gem is used internally at the [Radiofy](http://radiofy.se) project.

Follow me on [Twitter](http://twitter.com/linusoleander) for more info and updates.

## How to use

### Find a song

The `Spot::Search.find_song` method returns the first hit.

```` ruby
Spot::Search.find_song("Like Glue")
````

### Find all songs

The `find_all_songs` method returns a list of `Spot::Song` objects.

```` ruby
Spot::Search.find_all_songs("Like Glue")
````

### Find an artist

The `Spot::Search.find_artist` method returns the first hit.

```` ruby
Spot::Search.find_artist("Madonna")
````

### Find all artists

The `find_all_artists` method returns a list of `Spot::Artist` objects.

```` ruby
Spot::Search.find_all_artists("Madonna")
````

### Find an album

The `Spot::Search.find_album` method returns the first hit.

```` ruby
Spot::Search.find_album("Old Skool Of Rock")
````

### Find all albums

The `find_all_albums` method returns a list of `Spot::Album` objects.

```` ruby
Spot::Search.find_all_albums("Old Skool Of Rock")
````

### Find best match

The `prime` method makes it possible to fetch the best matching result based on the ingoing argument. It will reject data (songs, artists and albums) that contains any of the [these words](https://github.com/oleander/Spot/blob/master/lib/spot/ignore.yml).

``` ruby
Spot::Search.prime.find_song("Sweet Home Alabama")
```

### Specify a territory

All songs in Spotify isn't available everywhere.
It might therefore be usefull to specify a location, also know as a *territory*.

If you for example want to find all songs available in Sweden, then you might do something like this.

```` ruby
Spot::Search.territory("SE").find_song("Sweet Home Alabama")
````

You can find the complete territory list [here](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).

### Filter ingoing arguments

Sometimes it may be useful to filer ingoing params.  
You can filter the ingoing string by using the `strip` method.

```` ruby
Spot::Search.strip.find_song("3. Who's That Chick ? feat.Rihanna [Singel Version] - (Single)")
````

This is the string that is being passed to Spot.

    "who's that chick ?"

### Specify a page

```` ruby
Spot::Search.page(11).find_song("sweet home")
````

### Combine methods

You can easily chain method like this.

```` ruby
Spot::Search.page(11).territory("SE").prime.strip.find_song("sweet home")
````

## Data to work with

As soon as the `result` or `results` method is applied to the query a request to Spotify is made.

Here is an example (`#result`).

    >> song = Spot::Search.find_song("sweet home").result
    
    >> puts song.title
    => Home Sweet Home
    
    >> puts song.class
    => Spot::Song
 
Here is an example (`#results`).
   
    >> songs = Spot::Search.find_all_songs("sweet home").results
    >> puts songs.count
    => 100

### Base

`Spot::Song`, `Spot::Artist` and `Spot::Album` shares the following methods.

- **popularity** (*Float*) Popularity acording to Spotify. From `0.0` to `1.0`.
- **href** (*String*) Url for the specific object.
Default is a spotify url on this format: `spotify:track:5DhDGwNXRPHsMApbtVKvFb`.
`http` may be passed as a string, which will return an Spotify HTTP Url.
- **available?** (*Boolean*) Takes one argument, a territory. Returns true if the object is accessible in the given region.
Read more about it in the *Specify a territory* section above.
- **to_s** (*String*) A string representation of the object.
- **valid?** (*Boolean*) Returns true if the object is valid, a.k.a is accessible in the given territory. 
If no territory is given, this will be true.
- **name** (*String*) Same as `Spot::Song#title`.

### Song

Methods available for the `Spot::Song` class.

- **length** (*Fixnum*) Length in seconds.
- **title** (*String*) Song title.
- **to_s** (*String*) String representation of the object in this format: *artist - song*.
- **artist** (*Artist*) The artist.
- **album** (*Album*) The album.

### Artist

Methods available for the `Spot::Artist` class.

- **name** (*String*) Name of the artist.
- **to_s** (*String*) Same as above.

### Album

Methods available for the `Spot::Album` class.
    
- **artist** (*Artist*) The artist.

### Spot

```` ruby
spot = Spot::Search.find_song("kaizers orchestra")

puts spot.num_results # => 188
puts spot.limit       # => 100
puts spot.offset      # => 0
puts spot.query       # => "kaizers orchestra"
````

- **num_results** (*Fixnum*) The amount of hits.
- **limit** (*Fixnum*) The amount of results on each page.
- **query** (*String*) The search param that was passed to Spotify.
- **offset** (*Fixnum*)

## Request limit!

**Be aware**: Spotify has an request limit set for 10 requests per second.  
Which means that you can't just use it like this.

```` ruby
["song1", "song2", ...].each do |song|
  Spot::Search.find_song(song)
  # Do something with the data.
end
````

Instead use something like [Wire](https://github.com/oleander/Wire) to limit the amount of requests per seconds.

```` ruby
require "rubygems"
require "wire"
require "spot"

wires = []
["song1", "song2" ... ].each do |s|
  wires << Wire.new(max: 10, wait: 1, vars: [s]) do |song|
    Spot::Search.find_song(song)
    # Do something with the data.
  end
end

wires.map(&:join)
````

## How do install

    [sudo] gem install spot

## Requirements

*Spot* is tested in *OS X 10.6.7, 10.7.4* using Ruby *1.8.7*, *1.9.2*.

## License

*Spot* is released under the *MIT license*.