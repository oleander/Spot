# Spotify

An implementation of the [Spotify Meta API](http://developer.spotify.com/en/metadata-api/overview/).

The Spotify gem is being used internally in the [Radiofy](http://radiofy.se) project.

## How to use

### Find a song

The `Spotify.find_song` method returns the first hit.

```` ruby
Spotify.find_song("Like Glue")
````

### Find all songs

The `find_all_songs` method returns a list of `Song` objects.

```` ruby
Spotify.find_all_songs("Like Glue")
````

### Find an artist

The `Spotify.find_artist` method returns the first hit.

```` ruby
Spotify.find_artist("Madonna")
````

### Find all artists

The `find_all_artists` method returns a list of `Artist` objects.

```` ruby
Spotify.find_all_artists("Madonna")
````

### Find an album

The `Spotify.find_album` method returns the first hit.

```` ruby
Spotify.find_album("Old Skool Of Rock")
````

### Find all albums

The `find_all_albums` method returns a list of `Album` objects.

```` ruby
Spotify.find_all_albums("Old Skool Of Rock")
````

### Find the best match

The `prime` method makes it possible to filter out the best match based on the ingoing argument.

Here is what is being returned *without* the `prime` method.
 
    >> Spotify.find_song("sweet home").result
    => Home Sweet Home - Mötley Crüe

Here is what is being returned *with* the `prime` method.
    
    >> Spotify.prime.find_song("sweet home").result
    => Sweet Home Alabama - Lynyrd Skynyrd

The `prime` method will reject data (songs, artists and albums) that contains any of the [these words](https://github.com/oleander/Spotify/blob/master/lib/spotify/exclude.yml).

Here is the short version.

- tribute
- cover
- remix
- live
- club mix
- karaoke
- remaster
- club version
- demo
- made famous by
- remixes
- instrumental
- ringtone

Take a look at the [source code](https://github.com/oleander/Spotify/blob/master/lib/spotify.rb#L94) if you want to find out more.

### Specify a territory

All songs in Spotify isn't available everywhere.  
Therefore it might be usefull to specify a location, also know as a *territory*.

If you for example want to find all songs available in Sweden, then you might do something like.

```` ruby
Spotify.territory("SE").find_song("Sweet Home Alabama")
````

You can find the complete territory list [here](http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).

### Filter ingoing arguments

Sometimes it might be useful to filer ingoing params.  
You can filter the ingoing string by using the `strip` method.

```` ruby
Spotify.strip.find_song("3. Who's That Chick ? feat.Rihanna [Singel Version] - (Single)")
````

This is the string that is being passed to Spotify.

    "who's that chick ?"

Take a look at the [source code](https://github.com/oleander/Spotify/blob/master/lib/spotify.rb#L136) if you want to know what regexp is being used.

### Specify a page

You easely select any page you want by defining the `page` method.

```` ruby
Spotify.page(11).find_song("sweet home")
````

The default page is of course `1` :)

## Data to work with

As soon as the `result` or `results` method is applyed to the query a request to Spotify is made.

Here is an example using the `result` method.

    >> song = Spotify.find_song("sweet home").result
    >> puts song.title
    => Home Sweet Home
 
Here is an example using the `results` method.
   
    >> songs = Spotify.find_all_songs("sweet home").results
    >> puts songs.count
    => 100

### Base

All classes, `Song`, `Artist` and `Album` share these methods.

- **popularity** (*Float*) Popularity acording to Spotify. From `0.0` to `1.0`.
- **href** (*String*) Url for the specific object.
Default is a spotify url on this format: `spotify:track:5DhDGwNXRPHsMApbtVKvFb`.
`http` may be passed as a string, which will return an Spotify HTTP Url on this format: `http://open.spotify.com/track/5DhDGwNXRPHsMApbtVKvFb`.
- **available?** (*Boolean*) Takes one argument, a territory. Returns true if the object is accessible in the particular region.
Read more about it in the *Specify a territory* part above.
- **to_s** (*String*) A string representation of the object.
- **valid?** (*Boolean*) Returns true if the object is valid, a.k.a is accessible in the given territory. 
If no territory is given, then this will be true.
- **name** (*String*) Name of the `Song`, `Artist` or `Album`. This method will return the same thing as `Song.title`.

### Song

Here is the methods available for the `Song` class.

- **length** (*Fixnum*) Length in seconds.
- **title** (*String*) Song title.
- **to_s** (*String*) String representation of the object in this format: *song - artist*.
- **artist** (*Artist*) The artist.
- **album** (*Album*) The album.

### Artist

Here is the methods available for the `Artist` class.

- **name** (*String*) Name of the artist.
- **to_s** (*String*) Same as above.

### Album
    
- **artist** (*Artist*) The artist.

### Spotify

This one is easier to explain in code.

```` ruby
spotify = Spotify.find_song("kaizers orchestra")

puts spotify.num_results # => 188
puts spotify.limit       # => 100
puts spotify.offset      # => 0
puts spotify.query       # => "kaizers orchestra"
````

- **num_results** (*Fixnum*) The amount of results.
- **limit** (*Fixnum*) The amount of results on each page.
- **offset** (*Fixnum*) Unknown.
- **query** (*String*) The search param that was passed to Spotify.

## How do install

    [sudo] gem install spotify

## Requirements

*Spotify* is tested in *OS X 10.6.7* using Ruby *1.8.7*, *1.9.2*.

## License

*Spotify* is released under the *MIT license*.