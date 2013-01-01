module Lagrange
  module Interface
    ##
    # Mechanisms related to synchronizing bookmarks to/from Safari
    # `.webloc`/`.ftploc` files, and simple text files containing one URL per
    # line.
    #
    module MiscURL
      ##
      # The default name for the data file in the repository that will hold
      # data representing the last-seen-state of all raw bookmark imports.
      #
      DEFAULT_DATASET="misc_urls".freeze

      ##
      # The name for the directory in the repository in which all
      # raw-bookmark-related data is held.
      #
      INTERFACE_NAME="misc_urls".freeze

      ##
      # Ensure that any code needed by this subsystem is loaded once and only
      # once.
      #
      def self.init_dependencies!
        return if(defined?(@initialized) && @initialized)
        @initialized = true
        require 'plist'
      end

      ##
      # This subsystem allows the user to make many changes without committing
      # each one individually if they wish.  This method is for committing the
      # aggregate once the user has finished everything they're doing.
      #
      def self.snapshot(import_as, toolname)
        data_file = self.import_as(import_as)
        Lagrange::snapshot(data_file, toolname)
      end

      ##
      # Given a filename, will determine whether the file is a
      # `.webloc`/`.ftploc`, or a plain text file filled with URLs and will
      # import it into the native format in the repository accordingly.
      #
      def self.import(import_file, import_as, defer, toolname)
        import_file = Lagrange.raw_file(import_file)
        data_file = self.import_as(import_as)
        raise "Specified file does not exist: #{import_file.absolute}" if(!File.exists?(import_file.absolute))

        additions = []

        Lagrange.logger.info("Reading #{import_file.absolute}...")
        if(import_file.absolute =~ /\.(webloc|ftploc)$/)
          additions << Lagrange::FileTypes::Webloc.read(import_file.absolute)
        else
          additions += Lagrange::FileTypes::PlainText.read(import_file.absolute)
        end

        Lagrange.ensure_clean(data_file) unless(defer)

        if(File.exist?(data_file.absolute))
          current_data = Lagrange::FileTypes::JSON.read(data_file.absolute)
        else
          current_data = []
        end

        template = { created_at: DateTime.now.utc }
        additions = additions.map do |a_url|
          cleansed_url = Lagrange::DataTypes::URLs.cleanup(a_url[:url]).to_s
          template.merge(a_url.merge({
            cleansed_url: cleansed_url,
            uuid: Lagrange::DataTypes::URLs.uuid(cleansed_url),
          }))
        end

        current_urls = Hash[current_data.map { |bookmark| [bookmark[:cleansed_url], bookmark] }]
        updates = Hash[additions.select { |bookmark| current_urls.has_key?(bookmark[:cleansed_url]) }.map { |bookmark| [bookmark[:cleansed_url], bookmark] }]
        current_data = current_data.map do |a_url|
          if(updates[a_url[:cleansed_url]])
            ca = a_url[:created_at]
            a_url.merge!(updates[a_url[:cleansed_url]])
            a_url[:created_at] = ca if(ca)
          end
          a_url
        end

        creates = additions.reject { |bookmark| current_urls.has_key?(bookmark[:cleansed_url]) }
        if(additions.count != creates.count)
          Lagrange.logger.warn("Not adding #{additions.count-creates.count} duplicate URLs out of #{additions.count}!")
        end

        current_data += creates
        current_data = current_data.sort { |a, b| a[:uuid] <=> b[:uuid] }

        File.open(data_file.absolute, "wb") do |f|
          f.write(Lagrange::FileTypes::JSON.synthesize(current_data))
        end

        Lagrange::snapshot(data_file, toolname) unless(defer)
      end

    protected

      ##
      # Helper for when the user wants to maintain multiple sets of raw
      # bookmarks.  This handles turning a simple filename ("foo") into a fully
      # qualified path.
      #
      def self.import_as(as)
        misc_dir = Lagrange.interface_directory(Lagrange::Interface::MiscURL::INTERFACE_NAME)
        return Lagrange.data_file(misc_dir, "#{as}.json")
      end

    end
  end
end
