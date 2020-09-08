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
    #
    # @yieldparam [Object] record all record instances.
    def where
      all.select { |record| yield record }
    end

    # Returns the record matching the +id+.
    #
    # @return [Object, nil] the object if found, or +nil+.
    def find(id)
      attributes = cabinet[id]
      attributes ? new(attributes) : nil
    end
    alias [] find

    # @!group Deleting Records

    # Deletes a record matching the +id+
    #
    # @param [String] id the record ID.
    # @return [Boolean] +true+ on success, +false+ otherwise.
    def delete(id)
      !!cabinet.delete(id)
    end

    # Deletes all records.
    def drop
      cabinet.clear
    end

    # @!group Attribute Management

    # Returns an array containing {required_attributes} and {optional_attributes}.
    #
    # @return [Array<Symbol>] array of required attribute keys.
    def allowed_attributes
      optional_attributes + required_attributes
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
      if args.any?
        @optional_attributes = *args
      else
        @optional_attributes ||= []
      end
    end

    # @!group Utilities

    # Returns all records as a hash, with record IDs as the keys.
    def to_h
      cabinet.to_h.map { |id, attributes| [id, new(attributes)] }.to_h
    end

    # Returns the +HashCabinet+ instance.
    def cabinet
      @cabinet ||= HashCabinet.new "#{Config.dir}/#{cabinet_name}"
    end

  private

    def cabinet_name
      @cabinet_name ||= self.to_s.downcase.gsub('::', '_')
    end

  end
end
