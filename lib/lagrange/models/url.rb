module Lagrange
  module Models
    ##
    # URL represents the aggregate set of data -- both generic and
    # service/software-specific that we know about a particular URL.
    #
    # This class enforces certain basic data integrity requirements, and
    # handles automatic generation of derived data such as `canonical_url`
    # (the URL, clean according to RFC specs but semantically equivalent), and
    # `cleansed_url` (the URL, after applying parameter filtering, domain
    # substitution, and any other rules the user wishes to apply to filter out
    # 'noise' that may make same URLs seem to be different).
    #
    class URL < Model
      ##
      # A SHA1 based on the canonical URL and its length.
      #
      # __This should never be assigned manually.__
      #
      attribute :uuid,           String

      ##
      # The raw URL, as bookmarked by the user.  In the event that the same
      # `canonical_url` or `cleansed_url` appears multiple times with different
      # `raw_url` values, we'll likely pick the "oldest" `raw_url` as
      # authoritative.
      #
      # __This should never be changed once it is set.__
      #
      attribute :raw_url,        String

      ##
      # The result of cleaning up the `raw_url` and making it conform to RFCs
      # while attempting to leave it alone semantically.
      #
      # __This should never be assigned manually.__
      #
      attribute :canonical_url,  String

      ##
      # The result of applying the user's filtering/transformation rules to the
      # `canonical_url`.
      #
      # __This should never be assigned manually.__
      #
      attribute :cleansed_url,   String

      ##
      # The best title we can find to associate with the URL.
      #
      # This is subject to user modification at any time of course.
      #
      attribute :title,          String

      ##
      # An arbitrary structure containing data specific to each
      # service/software that we are syncing with.  The general format is that
      # it follows a two-tier namespace, one for the interface itself, and one
      # for the dataset the user is syncing.  That way, a user may have
      # multiple Pinboard accounts (or multiple accounts using that API), etc.
      #
      attribute :interface_data, AutoVivifyingOpenStruct, default: proc { |r, p| AutoVivifyingOpenStruct.new }

      ##
      # Ideally indicates when the user first bookmarked this URL, but may be
      # an approximation at best.
      #
      # __This should never be given a newer value than the previous one.__
      #
      attribute :created_at,     DateTime,                default: proc { |r, p| DateTime.now.utc }

      ##
      # Ideally indicates when the user most recently modified something
      # related to this URL, but may be an approximation at best.
      #
      # __This should never be given an older value than the previous one.__
      #
      attribute :updated_at,     DateTime,                default: proc { |r, p| DateTime.now.utc }

      validates_presence_of :uuid
      validates_length_of :uuid, equals: 40
      validates_format_of :uuid, with: /^[a-f0-9]+$/i

      validates_presence_of :raw_url, :canonical_url, :cleansed_url
      validates_length_of :raw_url, :canonical_url, :cleansed_url, within: 1..1024

      validates_presence_of :created_at
      validates_presence_of :updated_at

      ##
      # Sets the raw URL, and cascades this so that `canonical_url`,
      # `cleansed_url`, and `uuid` are all updated as well.
      #
      def raw_url=(val)
        self.canonical_url = val
        self.cleansed_url = val
        self.uuid = Lagrange::DataTypes::URLs.uuid(self.cleansed_url) unless(self.cleansed_url.blank?)
        @raw_url = val
      end

      ##
      # Provided with an ostensibly newer version of some subset of the data
      # about a URL, update this one as appropriate.
      #
      # The archetypal use-case is to take a service/software-specific URL
      # instance (I.E. one that does not have full metadata), and blend in the
      # updated data while leaving unrelated data undisturbed.
      #
      def merge!(new_version)
        raise "Uh, I need a Lagrange::Model::URL to work with!" if(!new_version.is_a?(Lagrange::Model::URL))
        raise "Can't combine records with different UUIDs!" if(self.uuid != new_version.uuid)
        raise "Can't combine records with different canonical URLs!" if(self.canonical_url != new_version.canonical_url)

        self.title = new_version.title if(!new_version.title.blank?)
        self.updated_at = new_version.updated_at if(new_version.updated_at > self.updated_at)

        self.interface_data.merge!(new_version.interface_data)
      end

    protected

      ##
      # Internal wrapper around `Lagrange::DataTypes::URLs.canonicalize`.
      #
      def canonical_url=(val); @canonical_url = Lagrange::DataTypes::URLs.canonicalize(val).to_s; end

      ##
      # Internal wrapper around `Lagrange::DataTypes::URLs.cleanup`.
      #
      def cleansed_url=(val); @cleansed_url = Lagrange::DataTypes::URLs.cleanup(val).to_s; end
    end
  end
end
