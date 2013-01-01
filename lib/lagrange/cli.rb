module Lagrange
  module CLI
    LAGRANGE_ASSUMED_TERM_WIDTH=79
    HELP_OPTIONS=['-?', '-h', '--help']
    VERSION_OPTIONS=['-v', '--version']
    USAGE_PREFIX="  "
    OPT_PREFIX="  "
    OPT_SUFFIX="    "
    GAP_OVERHEAD = OPT_PREFIX.length + OPT_SUFFIX.length

    def self.init_dependencies!
      return if(defined?(@initialized) && @initialized)
      @initialized = true
      require 'clint'
    end

    attr_accessor :clint, :toolname, :usage_messages, :help_messages
    def self.clint
      if(@clint.nil?)
        @clint = Clint.new
        @clint.usage do
          STDERR.puts(self.usage_messages.join("\n"))
        end
        @clint.help do
          msgs = self.help_messages.map do |line|
            if(line.is_a?(Array))
              [line.first.ensure_array.join(", "), line.last.ensure_array]
            else
              line
            end
          end

          max_option_length = msgs.
            map { |line| line.is_a?(Array) ? line.first.length : 0 }.
            max

          prefix=OPT_PREFIX + (" " * max_option_length) + OPT_SUFFIX

          processed_messages = msgs.map do |line|
            if(line.is_a?(Array))
              options = line.first

              msg = line.last.
                map { |l| l.word_wrap(LAGRANGE_ASSUMED_TERM_WIDTH - prefix.length).split(/\n/) }.
                flatten

              padding_length = prefix.length - (GAP_OVERHEAD + options.length)
              padding = " " * padding_length
              line = [
                "#{OPT_PREFIX}#{options}#{padding}#{OPT_SUFFIX}#{msg.shift}",
                msg.map { |l| "#{prefix}#{l}" }
              ].flatten.join("\n")
            elsif(!line.blank?)
              line = line.
                word_wrap(LAGRANGE_ASSUMED_TERM_WIDTH - OPT_PREFIX.length).
                split(/\n/).
                map { |l| "#{OPT_PREFIX}#{l}" }.
                join("\n")
            else
              line
            end
          end
          STDERR.puts(processed_messages.join("\n"))
        end
        add_usage_form({ required: [HELP_OPTIONS + VERSION_OPTIONS] })

        add_help_spacer
        add_option_with_help(HELP_OPTIONS, "Show this help message, then exit.")
        add_option_with_help(VERSION_OPTIONS, "Show version and copyright info.")
        add_help_spacer
      end
      return @clint
    end

    def self.toolname; @toolname; end
    def self.toolname=(val); @toolname = val; end

    def self.parse_options
      @clint.parse(ARGV)

      exit_flag = false
      if(@clint.options[:version])
        Lagrange::Version.show_version_info
        STDERR.puts("") if(@clint.options[:help])
        exit_flag = true
      end

      if(@clint.options[:help])
        @clint.help
        exit_flag = true
      end
      exit(1) if(exit_flag)
    end

    def self.add_usage_spacer
      usage_messages << ""
    end

    def self.add_usage_form(val)
      required = val[:required] || []
      optional = val[:optional] || []
      argument_spec = [
        required.map { |option_set| option_set.join('|') }.join(' '),
        optional.map { |option_set| "[#{option_set.join('|')}]" }.join(' ')
      ].reject { |s| s.blank? }.join(' ')
      usage_messages << "#{USAGE_PREFIX}#{File.basename(toolname)} #{argument_spec}"
    end

    def self.add_usage_heading(val)
      val = [val] unless(val.is_a?(Array))
      add_usage_spacer
      val.each do |line|
        usage_messages << line
      end
    end

    def self.add_option_with_usage_form(option_variants, message)
      self.add_usage_form({ required: [option_variants] })
      self.add_help_for_option(option_variants, message)
    end

    def self.add_option_with_help(option_variants, message, add_usage_form = false)
      option_variants = [option_variants] unless(option_variants.is_a?(Array))
      help_messages << [option_variants, message]

      option_map = {}
      option_primary = nil
      option_variants.sort { |a, b| b.length <=> a.length }.map do |variant|
        if matches = /^-(?<token>[a-z0-9?\/])(?: <.*?>)?$/i.match(variant)
          option_map[matches[:token].to_sym] = option_primary.to_sym
        elsif matches = /^--(?<token>[a-z0-9_-]+)(?<param>=<.*?>)?$/i.match(variant)
          option_primary = matches[:token].to_sym
          option_map[option_primary] = matches[:param] ? String : false
        else
          raise "Uh, not sure how to handle option '#{variant}'..."
        end
      end
      clint.options option_map
      self.add_usage_form({ required: [option_variants] }) if(add_usage_form)
    end

    def self.add_help_for_option(option_variants, message)
      option_variants = [option_variants] unless(option_variants.is_a?(Array))
      help_messages << [option_variants, message]
    end

    def self.add_help_spacer
      help_messages << ""
    end

    def self.add_help_heading(val)
      val = [val] unless(val.is_a?(Array))
      add_help_spacer
      val.each do |line|
        help_messages << line
      end
    end

  protected

    def self.usage_messages; clint; @usage_messages ||= ["Usage:"]; end
    def self.help_messages; clint; @help_messages ||= []; end
  end
end

