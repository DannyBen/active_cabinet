require 'hash_cabinet'
require 'forwardable'
require 'active_cabinet/config'

class ActiveCabinet
  class << self
    extend Forwardable
    def_delegators :cabinet, :count, :delete, :empty?, :keys, :size

    def []=(id, attributes)
      create attributes.merge(id: id)
    end

    def all
      cabinet.values.map do |attributes|
        new(attributes)
      end
    end

    def all_attributes
      optional_attributes + required_attributes
    end

    def cabinet
      @cabinet ||= HashCabinet.new "#{Config.dir}/#{cabinet_name}"
    end

    def create(attributes)
      record = new attributes
      record.save
    end

    def delete(id)
      !!cabinet.delete(id)
    end

    def drop
      cabinet.clear
    end

    def find(id)
      attributes = cabinet[id]
      attributes ? new(attributes) : nil
    end
    alias [] find

    def optional_attributes(*args)
      args = args.first if args.first.is_a? Array
      if args.any?
        @optional_attributes = *args
      else
        @optional_attributes ||= []
      end
    end

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

    def to_h
      cabinet.to_h.map { |id, attributes| [id, new(attributes)] }.to_h
    end

    def where
      all.select { |asset| yield asset }
    end

  private

    def cabinet_name
      @cabinet_name ||= self.to_s.downcase.gsub('::', '_')
    end

  end
end
