require 'clint'

module Lagrange
  class CLI
    def initialize(toolname)
      self.usage_messages ||= ["Usage:"]
      self.help_messages ||= []

      self.toolname = toolname

      add_usage_form({ required: [HELP_OPTIONS + VERSION_OPTIONS] })

      add_help_spacer
      add_option_with_help(HELP_OPTIONS, "Show this help message, then exit.")
      add_option_with_help(VERSION_OPTIONS, "Show version and copyright info.")
      add_help_spacer
    end

    def parse_options(opts)
      self.clint.parse(opts)

      continue_flag = true
      if(self.clint.options[:version])
        Lagrange::Version.show_version_info
        STDERR.puts("") if(self.clint.options[:help])
        continue_flag = false
      end

      if(self.clint.options[:help])
        self.clint.help
        continue_flag = false
      end

      self.has_parsed_options = true

      return continue_flag
    end

    def options
      raise "Must parse options first!" unless(self.has_parsed_options)
      return self.clint.options
    end

    def add_usage_spacer
      usage_messages << ""
    end

    def add_usage_form(val)
      required = val[:required] || []
      optional = val[:optional] || []
      argument_spec = [
        required.map { |option_set| option_set.join('|') }.join(' '),
        optional.map { |option_set| "[#{option_set.join('|')}]" }.join(' ')
      ].reject { |s| s.blank? }.join(' ')
      usage_messages << "#{USAGE_PREFIX}#{File.basename(toolname)} #{argument_spec}"
    end

    def add_usage_heading(val)
      val = [val] unless(val.is_a?(Array))
      add_usage_spacer
      val.each do |line|
        usage_messages << line
      end
    end

    def add_option_with_usage_form(option_variants, message)
      self.add_usage_form({ required: [option_variants] })
      self.add_help_for_option(option_variants, message)
    end

    def add_option_with_help(option_variants, message, add_usage_form = false)
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

    def add_help_for_option(option_variants, message)
      option_variants = [option_variants] unless(option_variants.is_a?(Array))
      help_messages << [option_variants, message]
    end

    def add_help_spacer
      help_messages << ""
    end

    def add_help_heading(val)
      val = [val] unless(val.is_a?(Array))
      add_help_spacer
      val.each do |line|
        help_messages << line
      end
    end

    attr_reader :toolname
  protected

    LAGRANGE_ASSUMED_TERM_WIDTH=79
    HELP_OPTIONS=['-?', '-h', '--help']
    VERSION_OPTIONS=['-v', '--version']
    USAGE_PREFIX="  "
    OPT_PREFIX="  "
    OPT_SUFFIX="    "
    GAP_OVERHEAD = OPT_PREFIX.length + OPT_SUFFIX.length

    attr_writer :toolname
    attr_accessor :usage_messages, :help_messages, :has_parsed_options

    def clint
      @clint ||= begin
        clint = Clint.new
        clint.usage do
          STDERR.puts(self.usage_messages.join("\n"))
        end
        clint.help do
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
        clint
      end
    end
  end
end

