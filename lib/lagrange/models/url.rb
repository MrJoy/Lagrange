module Lagrange
  module Models
    class URL < Model
      attribute :uuid,           String
      attribute :raw_url,        String
      attribute :canonical_url,  String
      attribute :cleansed_url,   String
      attribute :title,          String
      attribute :interface_data, AutoVivifyingOpenStruct, default: proc { |r, p| AutoVivifyingOpenStruct.new }

      attribute :created_at,     DateTime,                default: proc { |r, p| DateTime.now.utc }
      attribute :updated_at,     DateTime,                default: proc { |r, p| DateTime.now.utc }

      validates_presence_of :uuid
      validates_length_of :uuid, equals: 40
      validates_format_of :uuid, with: /^[a-f0-9]+$/i

      validates_presence_of :raw_url, :canonical_url, :cleansed_url
      validates_length_of :raw_url, :canonical_url, :cleansed_url, within: 1..1024

      validates_presence_of :created_at
      validates_presence_of :updated_at

      def raw_url=(val)
        self.canonical_url = val
        self.cleansed_url = val
        self.uuid = Lagrange::DataTypes::URLs.uuid(self.cleansed_url) unless(self.cleansed_url.blank?)
        @raw_url = val
      end

    protected

      def canonical_url=(val); @canonical_url = Lagrange::DataTypes::URLs.canonicalize(val).to_s; end
      def cleansed_url=(val); @cleansed_url = Lagrange::DataTypes::URLs.cleanup(val).to_s; end

      # def same_key(other)
      #   return false if(!other.is_a?(URL))
      #   return false if(other.uuid != self.uuid)
      #   return true
      # end
    end
  end
end
