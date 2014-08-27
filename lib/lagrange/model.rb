module Lagrange
  class Model
    include Virtus.model
    include DataMapper::Validations

    def as_json(*args)
      tmp = Hash.new
      self.attributes.sort.reject { |k,v| v.nil? }.each do |(key,value)|
        tmp[key] = value.respond_to?(:as_json) ? value.as_json(*args) : value
      end
      return tmp
    end

    def self.from_hash(hash)
      instance = self.new(false)
      instance.send(:from_hash!, hash)
      return instance
    end

  protected

    def from_hash!(hash)
      @property_names ||= self.class.attribute_set.map(&:name).to_set

      hash.each do |key, value|
        key = key.to_sym
        if(@property_names.include?(key))
          self.send("#{key}=".to_sym, value) # TODO: Would prefer to NOT go
                                             # TODO: through magic and just
                                             # TODO: deserialize directly here.
        end
      end
    end
  end
end
