require 'hash_cabinet'
require 'active_cabinet/metaclass'

class ActiveCabinet
  attr_reader :attributes, :error

  def initialize(attributes = {})
    @attributes = attributes.transform_keys(&:to_sym)
  end

  def all_attributes
    self.class.all_attributes
  end

  def method_missing(method_name, *args, &blk)
    name = method_name
    return attributes[name] if attributes.has_key? name

    suffix = nil

    if name.end_with?('=', '?')
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

  def optional_attributes
    self.class.optional_attributes
  end

  def reload
    return nil unless saved?
    update cabinet[id]
    self
  end

  def required_attributes
    self.class.required_attributes
  end

  def respond_to_missing?(method_name, include_private = false)
    name = method_name
    name = name[0..-2].to_sym if name.end_with?('=', '?')
    attributes.has_key?(name) || super
  end

  def save
    if valid?
      cabinet[id] = attributes
      self
    else
      false
    end
  end

  def saved?
    cabinet.key? id
  end

  def to_json
    attributes.to_json
  end

  def update(new_attributes)
    @attributes = attributes.merge new_attributes
  end

  def update!(new_attributes)
    update new_attributes
    save
  end

  def valid?
    missing_keys = required_attributes - attributes.keys
    if missing_keys.any?
      @error = "missing required attributes: #{missing_keys}"
      return false
    end

    if optional_attributes.any?
      invalid_keys = attributes.keys - all_attributes
      if invalid_keys.any?
        @error = "invalid attributes: #{invalid_keys}"
        return false
      end
    end

    true
  end

protected

  def cabinet
    self.class.cabinet
  end

end
