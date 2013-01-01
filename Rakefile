require 'rubygems'
begin
  ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', __FILE__)
  require 'bundler'
  Bundler.setup(:default, :development)
rescue Bundler::GemNotFound => e
  $stderr.puts(e.message)
  $stderr.puts("Try running `bundle install`.")
  exit!
end

require 'rake/dsl_definition'
require 'rake'
include Rake::DSL

require File.expand_path('../lib/lagrange', __FILE__)

task :environment do
  Lagrange.init!
end

FileList['tasks/**/*.rake'].each do |fname|
  load fname
end
