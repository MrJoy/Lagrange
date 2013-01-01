require 'rubygems'
begin
  ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)
  require 'bundler'
  Bundler.setup(:default, :test)
rescue Bundler::GemNotFound => e
  STDERR.puts(e.message)
  STDERR.puts("Try running `bundle install`.")
  exit!
end

$:.unshift(File.join(File.dirname(__FILE__), '../lib'))
$:.unshift(File.dirname(__FILE__))

require 'support/simplecov'

require 'rspec'
require 'pry'

Dir[File.expand_path("spec/support/etc/**/*.rb")].each { |f| require f }

require 'lagrange'
Lagrange.init!

RSpec.configure do |config|
end
