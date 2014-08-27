require 'clint'

module Lagrange
  class CLI
    def initialize(toolname)
      self.option_map = {}
      self.usage_map = {}
      self.usage_messages ||= ["Usage:"]
      self.help_messages ||= []

      self.toolname = toolname

      self.help_messages << ""
      add_options_with_help({
        help: {
          params: HELP_OPTIONS,
          message: "Show this help message, then exit.",
        },
        version: {
          params: VERSION_OPTIONS,
          message: "Show version and copyright info.",
        }
      })
      self.help_messages << ""

      add_usage_form(:help_or_version, { optional: [:help, :version] })
    end

    def parse_options(opts)
      self.clint.parse(opts)
      self.process_help_messages
      self.has_parsed_options = true

      self.option_map.each do |name, config|
        if(config[:default] && self.options[name].blank?)
          self.options[name] = config[:default]
        end
      end

      self.usage_form = nil
      candidate_forms = []
      self.usage_map.each do |name, config|
        is_missing_required_params = false
        missing_optional_params = 0

        config[:required].each do |opt|
          n = opt.keys.first
          is_missing_required_params = true if(self.options[n].blank?)
        end

        config[:optional].each do |opt|
          n = opt.keys.first
          missing_optional_params += 1 if(self.options[n].blank?)
        end

        requires_params = (config[:required].count > 0)
        has_any_optional_params = (missing_optional_params < config[:optional].count)
        if(!requires_params && !has_any_optional_params)
          is_missing_required_params = true
        end

        if(!is_missing_required_params)
          candidate_forms << name
        end

        if(candidate_forms.count > 1)
          Lagrange.logger.warn("Ambiguous parameters!")
        else
          self.usage_form = candidate_forms.first
        end
      end


      continue_flag = true
      if(self.options[:version])
        Lagrange::Version.extended_version_info.each do |line|
          Lagrange.logger.info line
        end
        Lagrange.logger.info "" if(self.options[:help])
        continue_flag = false
      end

      if(self.options[:help] || self.usage_form.nil?)
        self.clint.help
        continue_flag = false
      end

      return continue_flag
    end

    def options
      raise "Must parse options first!" unless(self.has_parsed_options)
      @options ||= self.clint.options
    end

    def add_usage_form(name, val)
      required = (val[:required] || []).map { |param| self.option_map[param][:params] }
      optional = (val[:optional] || []).map { |param| self.option_map[param][:params] }

      self.usage_map[name] = {
        required: required.map { |opts| convert_descriptions_to_params(opts, false) },
        optional: optional.map { |opts| convert_descriptions_to_params(opts, false) },
      }

      argument_spec = [
        required.map { |option_set| option_set.join('|') }.join(' '),
        optional.map { |option_set| "[#{option_set.join('|')}]" }.join(' ')
      ].reject { |s| s.blank? }.join(' ')
      usage_messages << "#{USAGE_PREFIX}#{File.basename(toolname)} #{argument_spec}"
    end

    def add_options_with_help(options)
      self.option_map.merge!(options)
      self.option_map.each do |name, config|
        self.add_option_with_help(config[:params], config[:message])
      end
    end

    attr_reader :usage_form, :toolname, :usage_messages, :processed_help_messages

  protected

    LAGRANGE_ASSUMED_TERM_WIDTH=79
    HELP_OPTIONS=['-?', '-h', '--help']
    VERSION_OPTIONS=['-v', '--version']
    USAGE_PREFIX="  "
    OPT_PREFIX="  "
    OPT_SUFFIX="    "
    GAP_OVERHEAD = OPT_PREFIX.length + OPT_SUFFIX.length

    attr_writer :usage_form, :toolname, :usage_messages, :processed_help_messages
    attr_accessor :option_map, :usage_map, :help_messages, :has_parsed_options

    def process_help_messages
      msgs = self.help_messages.map do |line|
        if(line.is_a?(Array))
          [Array(line.first).join(", "), Array(line.last)]
        else
          line
        end
      end

      max_option_length = msgs.
        map { |line| line.is_a?(Array) ? line.first.length : 0 }.
        max

      prefix=OPT_PREFIX + (" " * max_option_length) + OPT_SUFFIX

      self.processed_help_messages = msgs.map do |line|
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
    end

    def clint
      @clint ||= begin
        clint = Clint.new
        clint.usage do
          self.usage_messages.each do |line|
            Lagrange.logger.info line
          end
        end
        clint.help do
          self.processed_help_messages.each do |line|
            Lagrange.logger.info line
          end
        end
        clint
      end
    end

    def add_option_with_help(option_variants, message)
      option_variants = [option_variants] unless(option_variants.is_a?(Array))
      help_messages << [option_variants, message]

      self.clint.options convert_descriptions_to_params(option_variants)
    end

    def convert_descriptions_to_params(options, include_short_opts = true)
      option_map = {}
      option_primary = nil
      options.sort { |a, b| b.length <=> a.length }.map do |variant|
        if matches = /^-(?<token>[a-z0-9?\/])(?: <.*?>)?$/i.match(variant)
          if(include_short_opts)
            option_map[matches[:token].to_sym] = option_primary.to_sym
          end
        elsif matches = /^--(?<token>[a-z0-9_-]+)(?<param>=<.*?>)?$/i.match(variant)
          option_primary = matches[:token].to_sym
          option_map[option_primary] = matches[:param] ? String : false
        else
          raise "Uh, not sure how to handle option '#{variant}'..."
        end
      end

      return option_map
    end
  end
end

