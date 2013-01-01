require 'rubygems'
begin
  ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)
  # Only load and set things up if Bundler hasn't already been loaded, as we
  # may be in an environment-specific operating mode, etc.
  if(require 'bundler')
    Bundler.setup(:default)
  end
rescue Bundler::GemNotFound => e
  STDERR.puts(e.message)
  STDERR.puts("Try running `bundle install`.")
  exit!
end

$: << File.dirname(__FILE__)

module Lagrange
  def self.pre_init!
    return if(defined?(@pre_initialized) && @pre_initialized)
    @pre_initialized = true

    # Control the environment...
    ENV['TZ'] = 'utc'

    # Third party things we depend on...
    require 'set'
    require 'shellwords'
    require 'fileutils'
    require 'ostruct'
    require 'multi_json'
    require 'active_support/all'
    require 'virtus'

    # Hacks to things...
    require 'lagrange/monkeypatches'

    # Sub-modules...
    require 'lagrange/version'
    require 'lagrange/cli'
    Lagrange::CLI.init_dependencies!
    require 'lagrange/git'

    # Support logic...
    require 'lagrange/data_types/urls'
    Lagrange::DataTypes::URLs.init_dependencies!
  end

  def self.init!(module_name = nil)
    return if(defined?(@initialized) && @initialized)
    was_initialized = @initialized
    @initialized = module_name || true

    if(!was_initialized)
      # We haven't been initialized at all yet...
      self.pre_init!
      self.load_models!
      self.init_repository!
    end

    # We may have been initialized already but are being reinitialized with a
    # different module in mind...
    require "lagrange/modules/#{module_name}" if(!module_name.blank?)
  end

  def self.load_models!
    require 'lagrange/model'
    Dir[File.join(File.dirname(__FILE__), '/lagrange/models/**/*.rb')].each do |fname|
      require fname
    end
    # Lagrange::Model.finalize!
  end

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
      self.init_repository!(@repo)
    end
    return @repo
  end

  def self.init_repository!(repo=nil)
    if(repo == nil)
      repo = self.repository
    end
    unless(File.directory?(repo.absolute))
      STDERR.puts("Creating repository at: #{repo.short}")
      FileUtils.mkdir_p(repo.absolute) || raise("Couldn't create data directory in #{repo.short}!")
      # TODO: Use grit!
      STDERR.puts("Initializing repository...")
      system(%Q{
        cd #{repo.absolute_escaped}
        git init .
        git commit --allow-empty -m "Initial commit."
      }) || raise("Couldn't initialize git repository!")
    end
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
      STDERR.puts("Creating directory for module '#{module_name}' at: #{module_dir.absolute}")
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
    STDERR.puts("Snapshotting file in repo: #{file.relative}")
    system(%Q{
      cd #{Lagrange::repository.absolute_escaped} &&
      git add #{file.relative_escaped} &&
      git commit -m "Snapshotting, via #{Lagrange::CLI.toolname}" -- #{file.relative_escaped}
    })# || STDERR.puts("Had nothing to do, or got an error...")
  end
end

Lagrange.pre_init!
