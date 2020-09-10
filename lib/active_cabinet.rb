require 'hash_cabinet'
require 'active_cabinet/metaclass'

# @!attribute [r] attributes
#   @return [Hash] the attributes of the record
# @!attribute [r] error
#   @return [String, nil] the last validation error, after calling {valid?}
class ActiveCabinet
  attr_reader :attributes, :error

  # @!group Constructor

  # Initializes a new record with {attributes}
  #
  # @param [Hash] attributes record attributes
  def initialize(attributes = {})
    @attributes = default_attributes.merge attributes.transform_keys(&:to_sym)
  end

  # @!group Attribute Management

  # Returns an array containing {required_attributes} and {optional_attributes}.
  #
  # @return [Array<Symbol>] array of required attribute keys.
  def allowed_attributes
    self.class.allowed_attributes
  end

  # Returns an array of required record attributes. 
  #
  # @see ActiveCabinet.required_attributes.
  # @return [Array<Symbol>] the array of required attributes
  def required_attributes
    self.class.required_attributes
  end

  # Returns an array of optional record attributes. 
  #
  # @see ActiveCabinet.optional_attributes.
  # @return [Array<Symbol>] the array of optional attributes
  def optional_attributes
    self.class.optional_attributes
  end

  def default_attributes
    self.class.default_attributes
  end

  # Returns +true+ if the object is valid.
  # 
  # @return [Boolean] +true+ if the record is valid.
  def valid?
    missing_keys = required_attributes - attributes.keys
    if missing_keys.any?
      @error = "missing required attributes: #{missing_keys}"
      return false
    end

    if !optional_attributes or optional_attributes.any?
      invalid_keys = attributes.keys - allowed_attributes
      if invalid_keys.any?
        @error = "invalid attributes: #{invalid_keys}"
        return false
      end
    end

    true
  end

  # @!group Attribute Accessors

  # Returns the attribute value for the given key.
  #
  # @return [Object] the attribute value.
  def [](key)
    attributes[key]
  end

  # Sets the attribute value for the given key.
  #
  # @param [Symbol] key the attribute key.
  # @param [Object] value the attribute value.
  def []=(key, value)
    attributes[key] = value
  end

  # @!group Dynamic Attribute Accessors

  # Provides read/write access to {attributes}
  def method_missing(method_name, *args, &blk)
    name = method_name
    return attributes[name] if attributes.has_key? name

    suffix = nil

    if name.to_s.end_with?('=', '?')
      suffix = name[-1]
      name = name[0..-2].to_sym
    end

    case suffix
    when "="
      attributes[name] = args.first

    when "?"
      !!attributes[name]

    else
      super

    end
  end

  # Returns +true+ when calling +#respond_to?+ with an attribute name.
  #
  # @return [Boolean] +true+ if there is a matching attribute.
  def respond_to_missing?(method_name, include_private = false)
    name = method_name
    name = name[0..-2].to_sym if name.to_s.end_with?('=', '?')
    attributes.has_key?(name) || super
  end

  # @!group Loading and Saving 

  # Reads the attributes of the record from the cabinet and returns the 
  # record itself. If the record is not stored on disk, returns +nil+.
  #
  # @return [self, nil] the object or +nil+ if the object is not stored.
  def reload
    return nil unless saved?
    update cabinet[id]
    self
  end

  # Saves the record to the cabinet if it is valid. Returns the record on 
  # success, or +false+ on failure.
  #
  # @return [self, false] the record or +false+ on failure.
  def save
    if valid?
      cabinet[id] = attributes
      self
    else
      false
    end
  end

  # Returns +true+ if the record exists in the cabinet.
  #
  # @note This method only verifies that the ID of the record exists. The
  #   attributes of the instance and the stored record may differ.
  #
  # @return [Boolean] +true+ if the record is saved in the cabinet.
  def saved?
    cabinet.key? id
  end

  # Update the record with new or modified attributes.
  #
  # @param [Hash] new_attributes record attributes
  def update(new_attributes)
    @attributes = attributes.merge new_attributes
  end

  # Update the record with new or modified attributes, and save.
  #
  # @param [Hash] new_attributes record attributes
  def update!(new_attributes)
    update new_attributes
    save
  end

  # @!group Utilities

  # Returns a Hash of attributes
  #
  # @return [Hash<Symbol, Object>] the hash of attriibutes/
  def to_h
    attributes
  end

protected

  def cabinet
    self.class.cabinet
  end

end
