module Lagrange
  module Models
    class URL < Model
      attribute :uuid,           String
      attribute :url,            String
      attribute :canonical_url,  String
      attribute :cleansed_url,   String
      attribute :title,          String
      attribute :interface_data, AutoVivifyingOpenStruct, default: proc { AutoVivifyingOpenStruct.new }

      attribute :created_at,     DateTime
      attribute :updated_at,     DateTime

      # def url=(val)
      #   self.canonical_url = val
      #   self.cleansed_url = val
      #   self.uuid = Lagrange::DataTypes::URLs.uuid(self.cleansed_url) unless(self.cleansed_url.blank?)
      #   @url = val
      # end

      # attr_reader :canonical_url
      # def canonical_url=(val); @canonical_url = Lagrange::DataTypes::URLs.canonicalize(val).to_s; end

      # attr_reader :cleansed_url
      # def cleansed_url=(val); @cleansed_url = Lagrange::DataTypes::URLs.cleanup(val).to_s; end

      # def same_key(other)
      #   return false if(!other.is_a?(URL))
      #   return false if(other.uuid != self.uuid)
      #   return true
      # end
    end
  end
end
