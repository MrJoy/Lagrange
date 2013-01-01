module Lagrange
  module CLI
    LAGRANGE_ASSUMED_TERM_WIDTH=79

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
          max_option_length = self.help_messages.map do |line|
            if(line.is_a?(Array))
              options = line.first.ensure_array.join(", ")
              options.length
            else
              0
            end
          end.max

          initial_prefix="    "
          initial_suffix="      "
          continuing_prefix=initial_prefix + (" " * max_option_length) + initial_suffix

          processed_messages = self.help_messages.map do |line|
            if(line.is_a?(Array))
              options = line.first.ensure_array.join(", ")

              msg = line.last.ensure_array.
                map { |l| l.word_wrap(LAGRANGE_ASSUMED_TERM_WIDTH - continuing_prefix.length).split(/\n/) }.
                flatten

              padding_length = continuing_prefix.length - (initial_prefix.length + options.length + initial_suffix.length)
              line = [
                "#{initial_prefix}#{options}#{" " * padding_length}#{initial_suffix}#{msg.shift}",
                msg.map { |l| "#{continuing_prefix}#{l}" }
              ].join("\n")
            elsif(line != "")
              line = line.
                word_wrap(LAGRANGE_ASSUMED_TERM_WIDTH - initial_prefix.length).
                split(/\n/).
                map { |l| "#{initial_prefix}#{l}" }.
                join("\n")
            else
              line
            end
          end
          #STDERR.puts("processed_messages=#{processed_messages.inspect}")
          STDERR.puts(processed_messages.join("\n"))
        end
        @clint.options :help => false, :h => :help, :'?' => :help
        @clint.options :version => false, :v => :version
        add_usage_form("[-v|--version] [-?|-h|--help]")

        add_help_spacer
        add_help_for_option(["-?", "-h", "--help"], "Show this help message, then exit.")
        add_help_for_option(["-v", "--version"], "Show version and copyright info.")
        add_help_spacer
      end
      return @clint
    end

    def self.toolname; @toolname; end
    def self.toolname=(val); @toolname = val; end

    def self.parse_options
      @clint.parse(ARGV)

      if(@clint.options[:version])
        Lagrange::Version.show_version_info
        STDERR.puts("") if(@clint.options[:help])
        exit 1
      end

      if(@clint.options[:help])
        @clint.help
        exit 1
      end
    end

    def self.add_usage_spacer
      usage_messages << ""
    end

    def self.add_usage_form(val)
      val = [val] unless(val.is_a?(Array))
      val.each do |line|
        usage_messages << "    #{File.basename(toolname)} #{line}"
      end
    end

    def self.add_usage_heading(val)
      val = [val] unless(val.is_a?(Array))
      add_usage_spacer
      val.each do |line|
        usage_messages << line
      end
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

