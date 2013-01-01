#!/usr/bin/env ruby
LAGRANGE_PATH = File.expand_path('../../../',  __FILE__)
require File.expand_path("#{LAGRANGE_PATH}/lib/boot")
require 'lagrange/mirrord'


Lagrange::toolname = __FILE__

options = ["-i <name>", "--import=<name>"]
Lagrange::add_usage_form("[#{options.join('|')}]")
Lagrange::add_help_for_option(
  options,
  "Import the specified Mirror'd bookmark set to the native format.  If this option is ommitted, then Lagrange will default to naming the data set after the specified username.",
)
Lagrange::clint.options import: String, i: :import

options = ["-u <username>", "--user=<username>"]
Lagrange::add_usage_form("[#{options.join('|')}]")
Lagrange::add_help_for_option(
  options,
  "Authenticate using the specified username.",
)
Lagrange::clint.options user: String, u: :user

options = ["-p <password>", "--password=<password>"]
Lagrange::add_usage_form("[#{options.join('|')}]")
Lagrange::add_help_for_option(
  options,
  "Authenticate using the specified password.",
)
Lagrange::clint.options password: String, p: :password

Lagrange::parse_options

username = Lagrange::clint.options[:user].downcase
password = Lagrange::clint.options[:password]

raise("Must specify user, and password!") unless(username != "" and password != "")

import_set = (Lagrange::clint.options[:import] != "") ? Lagrange::clint.options[:import] : username

mirrord_dir = Lagrange::module_directory(Lagrange::Mirrord::MODULE_NAME)
native_file = Lagrange::data_file(mirrord_dir, "#{import_set}.yml")
Lagrange::ensure_clean(native_file)

Mirrored::Base.establish_connection(:delicious, username, password)
last_update_stamp = Mirrored::Update.last
tags=Mirrored::Tag.find(:get).map { |tag| tag.name }.sort
posts=Mirrored::Post.find(:all).map do |post|
  cleansed_url = Lagrange::URLs.cleanup(post.href).to_s
  {
    url: post.href,
    cleansed_url: cleansed_url,
    uuid: Lagrange::URLs.uuid(cleansed_url),
    description: post.description,
    extended: post.extended,
    others: post.others,
    tags: post.tags,
    created_at: post.time,
    mirrord_uuid: post.hash,
  }
end.sort { |a, b| a[:uuid] <=> b[:uuid] }

puts "Server Reports Last Update: #{last_update_stamp.strftime("%Y-%m-%d %H:%M:%S %z")}"
puts "Found #{tags.count} tags, and #{posts.count} posts."

File.open(native_file.absolute, "w") do |f|
  f.write({
    last_update: last_update_stamp,
    tags: tags,
    posts: posts,
  }.to_yaml)
end

Lagrange::snapshot(native_file)
