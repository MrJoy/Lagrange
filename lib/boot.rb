require 'rubygems'
gemfile = File.expand_path('../../Gemfile', __FILE__)
begin
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  $stderr.puts(e.message)
  $stderr.puts("Try running `bundle install`.")
  exit!
end
Bundler.require(:default)


require 'shellwords'
require 'fileutils'
require 'ostruct'
$: << File.expand_path('..', __FILE__)


LAGRANGE_ASSUMED_TERM_WIDTH=79
require 'lagrange/monkeypatches'


module Lagrange
  VERSION="0.0.2".freeze
  RELEASE_DATE="2012-06-13".freeze

  def self.repository
    # TODO: This is rather OSX-specific...  *cough*
    if(@repo.nil?)
      short_path="~/Library/Application Support/Lagrange"
      absolute_path=File.expand_path(short_path)
      @repo = OpenStruct.new({
        short: short_path,
        short_escaped: Shellwords.shellescape(short_path),
        absolute: absolute_path,
        absolute_escaped: Shellwords.shellescape(absolute_path),
      })
      unless(File.directory?(@repo.absolute))
        $stderr.puts("Creating repository at: #{@repo.short}")
        FileUtils.mkdir_p(@repo.absolute) || raise("Couldn't create data directory in #{@repo.short}!")
        # TODO: Use grit!
        $stderr.puts("Initializing repository...")
        system(%Q{
          cd #{@repo.absolute_escaped}
          git init .
          git commit --allow-empty -m "Initial commit."
        }) || raise("Couldn't initialize git repository!")
      end
    end
    return @repo
  end

  def self.module_directory(module_name)
    absolute_dir = File.join(Lagrange::repository.absolute, module_name)

    module_dir = OpenStruct.new({
      absolute: absolute_dir,
      absolute_escaped: Shellwords.shellescape(absolute_dir),
      relative: module_name,
      relative_escaped: Shellwords.shellescape(module_name),
    })

    unless(File.directory?(module_dir.absolute))
      $stderr.puts("Creating directory for module '#{module_name}' at: #{module_dir.absolute}")
      FileUtils.mkdir_p(module_dir.absolute) || raise("Can't ensure #{module_dir.absolute} exists!")
    end
    return module_dir
  end

  def self.raw_file(filename)
    data = OpenStruct.new({
      absolute: File.expand_path(filename),
      absolute_escaped: Shellwords.shellescape(File.expand_path(filename)),
    })

    return data
  end

  def self.config_file(filename)
    absolute_name = File.join(Lagrange::repository.absolute, filename)
    data = OpenStruct.new({
      absolute: absolute_name,
      absolute_escaped: Shellwords.shellescape(absolute_name),
    })

    return data
  end

  def self.data_file(module_dir, filename)
    relative_name = File.join(module_dir.relative, filename)
    absolute_name = File.join(Lagrange::repository.absolute, relative_name)
    data = OpenStruct.new({
      relative: relative_name,
      relative_escaped: Shellwords.shellescape(relative_name),
      absolute: absolute_name,
      absolute_escaped: Shellwords.shellescape(absolute_name),
      module_home: module_dir,
    })

    return data
  end

  def self.ensure_clean(file)
    if(File.exist?(file.absolute))
      # TODO: Use grit!
      status = `cd #{Lagrange::repository.absolute_escaped}; git status --porcelain #{file.relative_escaped}`.chomp.split(/\s+/).first || ""
      raise "Uh oh!  File '#{file.absolute}' is dirty -- please ensure it's clean before trying to import more changes!  Got status code of '#{status}'." if(status != "")
    end
  end

  def self.snapshot(file)
    # TODO: Use Grit!
    $stderr.puts("Snapshotting file in repo: #{file.relative}")
    system(%Q{
      cd #{Lagrange::repository.absolute_escaped} &&
      git add #{file.relative_escaped} &&
      git commit -m "Snapshotting, via #{Lagrange.toolname}" -- #{file.relative_escaped}
    })# || $stderr.puts("Had nothing to do, or got an error...")
  end

  def self.show_version_info
    $stderr.puts("Lagrange version #{VERSION}, #{RELEASE_DATE}")
    $stderr.puts("(C)Copyright 2011-2012, Jon Frisby.")
  end

  attr_accessor :clint, :toolname, :usage_messages, :help_messages
  def self.clint
    if(@clint.nil?)
      @clint = Clint.new
      @clint.usage do
        $stderr.puts(Lagrange::usage_messages.join("\n"))
      end
      @clint.help do
        max_option_length = Lagrange::help_messages.map do |line|
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

        processed_messages = Lagrange::help_messages.map do |line|
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
        #$stderr.puts("processed_messages=#{processed_messages.inspect}")
        $stderr.puts(processed_messages.join("\n"))
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
      Lagrange::show_version_info
      $stderr.puts("") if(@clint.options[:help])
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

require 'lagrange/urls'
require 'lagrange/git'
