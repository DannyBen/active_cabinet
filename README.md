ActiveCabinet
==================================================

---

ActiveCabinet is an ActiveRecord-inspired interface for HashCabinet, the
file-basd key-object store.

It allows you to create models that are stored in a file-based key-value
store, backed by Ruby's built in [SDBM].

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

You may specify required arguments. Records without these attributes will
not be saved. Note that `id` is always required

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

```
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

### Configuring storage path

By default, `ActiveCabinet` stores all its files (two files per model) in the
`./db` directory. The file name is determined by the name of the class.

You can override both of these values

```ruby
# Set the based directory for all cabinets
ActiveCabinet::Config.dir = "cabinets"

# Set the filename of your model
class Song < ActiveCabinet
  cabinet_name "songs_collection"
end
```

For the full documentation, see the [Documentation on RubyDoc][docs]


[SDBM]: https://ruby-doc.org/stdlib-2.6.3/libdoc/sdbm/rdoc/SDBM.html
[docs]: https://rubydoc.info/gems/active_cabinet

---

[SDBM]: https://ruby-doc.org/stdlib-2.7.1/libdoc/sdbm/rdoc/SDBM.html