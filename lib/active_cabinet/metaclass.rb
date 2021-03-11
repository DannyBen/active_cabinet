require 'hash_cabinet'
require 'forwardable'
require 'active_cabinet/config'

# {ActiveCabinet} lets you create a +HashCabinet+ collection model by
# subclassing {ActiveCabinet}:
#
#   class Song < ActiveCabinet
#   end
#
# Now, you can perform CRUD operations on this collection, which will be
# persisted to disk:
#
#   # Create
#   Song.create id: 1, title: 'Moonchild', artist: 'Iron Maiden'
#
#   # Read
#   moonchild = Song[1] # or Song.find 1
#
#   # Update
#   moonchild.title = "22 Acacia Avenue"
#   moonchild.save
#   # or
#   moonchild.update! title: "22 Acacia Avenue"
#
#   # Delete
#   Song.delete 1
#   
class ActiveCabinet
  class << self
    extend Forwardable
    def_delegators :cabinet, :count, :delete, :empty?, :keys, :size

    # @!group Creating Records

    # Creates and saves a new record instance.
    #
    # @param [String] id the record id.
    # @param [Hash] attributes the attributes to create.
    def []=(id, attributes)
      create attributes.merge(id: id)
    end

    # Creates and saves a new record instance.
    #
    # @param [Hash] attributes the attributes to create.
    # @return [Object] the record.
    def create(attributes)
      record = new attributes
      record.save || record
    end

    # @!group Reading Records

    # Returns all records.
    #
    # @return [Array] array of all records.
    def all
      cabinet.values.map do |attributes|
        new(attributes)
      end
    end

    # Returns all records, as an Array of Hashes.
    #
    # @return [Array] array of all records.
    def all_attributes
      cabinet.values
    end

    # Returns an array of records for which the block returns true.
    # When +query+ is provided, it should be a Hash with a single key and
    # value. The result will be records that have a matching attribute.
    #
    # @example Search using a Hash query
    #   Song.where artist: "Iron Maiden"
    #
    # @example Search using a block
    #   Song.where { |record| record[:artist] == "Iron Maiden" }
    #
    # @yieldparam [Object] record all record instances.
    # @return [Array<Object>] record all record instances.
    def where(query = nil)
      if query
        key, value = query.first
        all.select { |record| record[key] == value }
      else
        all.select { |record| yield record }
      end
    end

    # Returns the record matching the +id+.
    # When providing a Hash with a single key-value pair, it will return the
    # first matching object from the respective {where} query.
    #
    # @example Retrieve a record by ID
    #   Song.find 1
    #   Song[1]
    #
    # @example Retrieve a different attributes
    #   Song.find artist: "Iron Maiden"
    #   Song[artist: "Iron Maiden"]
    #
    # @return [Object, nil] the object if found, or +nil+.
    def find(id)
      if id.is_a? Hash
        where(id).first
      else
        attributes = cabinet[id]
        attributes ? new(attributes) : nil
      end
    end
    alias [] find

    # Yields each record to the given block.
    #
    # @yieldparam [Object] record all record instances.
    def each
      cabinet.each_value do |attributes|
        yield new(attributes)
      end
    end

    # Returns the first record.
    #
    # @return [Object] the record.
    def first
      find keys.first
    end

    # Returns the last record.
    #
    # @return [Object] the record.
    def last
      find keys.last
    end

    # Returns a random racord.
    #
    # @return [Object] the record.
    def random
      find keys.sample
    end

    # @!group Deleting Records

    # Deletes a record matching the +id+.
    #
    # @param [String] id the record ID.
    # @return [Boolean] +true+ on success, +false+ otherwise.
    def delete(id)
      !!cabinet.delete(id)
    end

    # Deletes a record for which the block returns true.
    #
    # @example Delete records using a block
    #   Song.delete_if { |record| record[:artist] == "Iron Maiden" }
    def delete_if(&block)
      cabinet.delete_if { |key, _value| yield self[key] }
    end

    # Deletes all records.
    def drop
      cabinet.clear
    end

    # @!group Attribute Management

    # Returns an array containing the keys of all allowed attributes as
    # defined by {required_attributes}, {optional_attributes} and 
    # {default_attributes}.
    #
    # @return [Array<Symbol>] array of required attribute keys.
    def allowed_attributes
      (optional_attributes || []) + required_attributes + default_attributes.keys
    end

    # Sets the required record attribute names.
    #
    # @param [Array<Symbol>] *attributes one or more attribute names.
    # @return [Array<Symbol>] the array of required attributes.
    def required_attributes(*args)
      args = args.first if args.first.is_a? Array
      if args.any?
        @required_attributes = args
        @required_attributes.push :id unless @required_attributes.include? :id
        @required_attributes
      else
        @required_attributes ||= [:id]
      end
    end

    # Sets the optional record attribute names.
    #
    # @param [Array<Symbol>] *attributes one or more attribute names.
    # @return [Array<Symbol>] the array of optional attributes.
    def optional_attributes(*args)
      args = args.first if args.first.is_a? Array
      if args.first === false
        @optional_attributes = false
      elsif args.any?
        @optional_attributes = *args
      else
        @optional_attributes.nil? ? [] : @optional_attributes
      end
    end

    # Sets the default record attribute values.
    #
    # @param [Hash<Symbol, Object>] **attributes one or more attribute names and values.
    # @return [Hash<Symbol, Object>] the hash of the default attributes.
    def default_attributes(args = nil)
      if args
        @default_attributes = args
      else
        @default_attributes ||= {}
      end
    end

    # @!group Utilities

    # Returns all records as a hash, with record IDs as the keys.
    def to_h
      cabinet.to_h.map { |id, attributes| [id, new(attributes)] }.to_h
    end

    # Returns the +HashCabinet+ instance.
    #
    # @return [HashCabinet] the +HashCabinet+ object.
    def cabinet
      @cabinet ||= HashCabinet.new "#{Config.dir}/#{cabinet_name}"
    end

    # Returns or sets the cabinet name. 
    # Defaults to the name of the class, lowercase.
    #
    # @param [String] name the name of the cabinet file.
    # @return [String] name the name of the cabinet file.
    def cabinet_name(new_name = nil)
      if new_name
        @cabinet = nil
        @cabinet_name = new_name
      else
        @cabinet_name ||= self.to_s.downcase.gsub('::', '_')
      end
    end

  end
end
