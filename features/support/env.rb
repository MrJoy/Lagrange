require 'rubygems'
begin
  ENV['BUNDLE_GEMFILE'] = File.expand_path('../../../Gemfile', __FILE__)
  require 'bundler'
  Bundler.setup(:default, :test)
rescue Bundler::GemNotFound => e
  STDERR.puts(e.message)
  STDERR.puts("Try running `bundle install`.")
  exit!
end

$:.unshift(File.join(File.dirname(__FILE__), '../lib'))
$:.unshift(File.dirname(__FILE__))

require File.expand_path('../../../spec/support/simplecov', __FILE__)
