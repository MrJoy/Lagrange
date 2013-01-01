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
    require 'logger'
    require 'shellwords'
    require 'fileutils'
    require 'ostruct'
    require 'yajl'
    require 'multi_json'
    require 'active_support/all'
    require 'virtus'

    # Hacks to things...
    require 'lagrange/monkeypatches'
    require 'lagrange/inflections'

    # Sub-modules...
    require 'lagrange/version'
    require 'lagrange/cli'
    require 'lagrange/git'

    # Support logic for specific data types...
    require 'lagrange/data_types/urls'
    Lagrange::DataTypes::URLs.init_dependencies!

    # Support logic for specific file formats...
    require 'lagrange/file_types/json'
    require 'lagrange/file_types/webloc'
    require 'lagrange/file_types/plain_text'
  end

  def self.init!(interface_name = nil)
    return if(defined?(@initialized) && @initialized)
    was_initialized = @initialized
    @initialized = interface_name || true

    if(!was_initialized)
      # We haven't been initialized at all yet...
      self.pre_init!
      self.load_models!
      self.init_repository!
    end

    # We may have been initialized already but are being reinitialized with a
    # different interface in mind...
    if(!interface_name.blank?)
      name = "lagrange/interface/#{interface_name}"
      require name
      name.classify.constantize.init_dependencies!
    end
  end

  def self.load_models!
    require 'lagrange/model'
    Dir[File.join(File.dirname(__FILE__), '/lagrange/models/**/*.rb')].each do |fname|
      require fname
    end
  end

  def self.logger=(logger); @@logger = logger; end
  def self.logger; @@logger ||= Logger.new(STDOUT); end

  def self.repository
    # TODO: This is rather OSX-specific...  *cough*
    if(@repo.nil?)
      short_path="~/Library/Application Support/Lagrange"
      absolute_path=File.expand_path(short_path)
      @repo = OpenStruct.new({
        short: short_path,
        absolute: absolute_path,
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
      self.logger.info("Creating repository at: #{repo.short}")
      FileUtils.mkdir_p(repo.absolute) || raise("Couldn't create data directory in #{repo.short}!")
      # TODO: Use grit!
      self.logger.info("Initializing repository...")
      system(%Q{
        cd #{repo.absolute.shellescape}
        git init .
        git commit --allow-empty -m "Initial commit."
      }) || raise("Couldn't initialize git repository!")
    end
  end

  def self.interface_directory(interface_name)
    absolute_dir = File.join(Lagrange::repository.absolute, interface_name)

    interface_dir = OpenStruct.new({
      absolute: absolute_dir,
      relative: interface_name,
    })

    unless(File.directory?(interface_dir.absolute))
      self.logger.info("Creating directory for interface '#{interface_name}' at: #{interface_dir.absolute}")
      FileUtils.mkdir_p(interface_dir.absolute) || raise("Can't ensure #{interface_dir.absolute} exists!")
    end
    return interface_dir
  end

  def self.raw_file(filename)
    data = OpenStruct.new({
      absolute: File.expand_path(filename),
    })

    return data
  end

  def self.config_file(filename)
    absolute_name = File.join(Lagrange::repository.absolute, filename)
    data = OpenStruct.new({
      absolute: absolute_name,
    })

    return data
  end

  def self.data_file(interface_dir, filename)
    relative_name = File.join(interface_dir.relative, filename)
    absolute_name = File.join(Lagrange::repository.absolute, relative_name)
    data = OpenStruct.new({
      relative: relative_name,
      absolute: absolute_name,
      interface_home: interface_dir,
    })

    return data
  end

  def self.ensure_clean(file)
    if(File.exist?(file.absolute))
      # TODO: Use grit!
      status = `cd #{Lagrange::repository.absolute.shellescape}; git status --porcelain #{file.relative.shellescape}`.chomp.split(/\s+/).first || ""
      raise "Uh oh!  File '#{file.absolute}' is dirty -- please ensure it's clean before trying to import more changes!  Got status code of '#{status}'." if(status != "")
    end
  end

  def self.snapshot(file, toolname)
    # TODO: Use Grit!
    self.logger.info("Snapshotting file in repo: #{file.relative}")
    system(%Q{
      cd #{Lagrange::repository.absolute.shellescape} &&
      git add #{file.relative.shellescape} &&
      git commit -m "Snapshotting, via #{toolname}" -- #{file.relative.shellescape}
    })# || self.logger.warn("Had nothing to do, or got an error...")
  end
end

Lagrange.pre_init!
