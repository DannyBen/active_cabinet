ActiveCabinet
==================================================

An ActiveRecord-inspired interface for [HashCabinet], the
file-based key-object store.

It allows you to create models that are stored in a file-based key-value
store, backed by Ruby's built in [SDBM].

ActiveCabinet is a tiny library, with only [HashCabinet] as a dependency.

---

Installation
--------------------------------------------------

    $ gem install active_cabinet



Usage
--------------------------------------------------

Before trying these examples, create a directory named `db` - this is the 
default directory where the cabinet files are stored.

```ruby
require 'active_cabinet'

# Define a model
class Song < ActiveCabinet
end

# Create the model, and store it in the cabinet
# Each object must have at least an `id` and can have any number of
# attributes
song = Song.create id: 1, title: 'Moonchild', artist: 'Iron Maiden'
p song
#=> #<Song @attributes={:id=>1, :title=>"Moonchild", :artist=>"Iron Maiden"}>

# Get all records
Song.all     #=> Array of Song objects
Song.count   #=> 1

# Retrieve a specific record
Song[1]
Song.find 1

# Read one attribute or all attributes from a record
song.album
song.attributes

# Update a single attribute
song.year = 1988
song.save

# Update multiple attributes
song.update year: 1988, artist: 'Metallica'
song.update! year: 1988, artist: 'Metallica'  # this variant also saves
```

### Restricting / allowing certain attributes

You may specify required attributes. Records without these attributes will
not be saved. Note that `id` is always required.

```ruby
class Song < ActiveCabinet
  required_attributes :title, :artist
end

song = Song.new title: "Moonchild"
song.valid?   # => false
song.error    # => "missing required attributes: [:artist, :id]"

song = Song.new id: 1, title: "Moonchild", artist: 'Iron Maiden'
song.valid?   # => true

# Additional attributes are still allowed
song.year = 1988
song.valid?   # => true
```

You can also restrict the allowed optional attributes

```ruby
class Song < ActiveCabinet
  required_attributes :title
  optional_attributes :artist
end

song = Song.new id: 1, title: 'Moonchild', album: 'Seventh Son of a Seventh Son'
song.valid?  # => false
song.error   # => "invalid attributes: [:album]"
```

In order to enforce only the required attributes, without optional ones, set
the value of `optional_attributes` to `false`

```ruby
class Song < ActiveCabinet
  required_attributes :title
  optional_attributes false
end

song = Song.new id: 1, title: 'Moonchild', artist: 'Iron Maiden'
song.valid?  # => false
song.error   # => "invalid attributes: [:artist]"
```

### Declaring default attribute values

You may specify default values for some attributes. These attrributes will
be merged into newly created record instances.

```ruby
class Song < ActiveCabinet
  required_attributes :title
  default_attributes format: :mp3
end

song = Song.new title: "Moonchild"
song.format   # => :mp3
```


### Configuring storage path

By default, `ActiveCabinet` stores all its files (two files per model) in the
`./db` directory. The file name is determined by the name of the class.

You can override both of these values:

```ruby
# Set the base directory for all cabinets
ActiveCabinet::Config.dir = "cabinets"

# Set the filename of your model
class Song < ActiveCabinet
  cabinet_name "songs_collection"
end
```

## Documentation

[Documentation on RubyDoc][docs]

## Contributing / Support

If you experience any issue, have a question or a suggestion, or if you wish
to contribute, feel free to [open an issue][issues].

---

[SDBM]: https://ruby-doc.org/stdlib-2.7.1/libdoc/sdbm/rdoc/SDBM.html
[docs]: https://rubydoc.info/gems/active_cabinet
[issues]: https://github.com/DannyBen/active_cabinet/issues
[HashCabinet]: https://github.com/DannyBen/hash_cabinet
