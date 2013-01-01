#!/usr/bin/env ruby
LAGRANGE_PATH = File.expand_path('../../../',  __FILE__)
require File.expand_path("#{LAGRANGE_PATH}/lib/lagrange")
Lagrange.init!('mirrord')


cli = Lagrange::CLI.new(__FILE__)

cli.add_options_with_help({
  user: {
    params: ["-u <username>", "--user=<username>"],
    message: "Authenticate using the specified username.",
  },
  password: {
    params: ["-p <password>", "--password=<password>"],
    message: "Authenticate using the specified password.",
  },
  as: {
    params: ["-a <name>", "--as=<name>"],
    message: "Save the data under the name repo/#{Lagrange::Interface::Mirrord::INTERFACE_NAME}/<name>.json.  Defaults to '<username>.json'.",
  },
})

cli.add_usage_form(:default, { required: [:user, :password], optional: [:as] })

exit(1) unless(cli.parse_options(ARGV))
OPTIONS = cli.options

username = OPTIONS[:user].downcase
password = OPTIONS[:password]

raise("Must specify user, and password!") unless(username != "" and password != "")

import_set = (OPTIONS[:as] != "") ? OPTIONS[:as] : username

mirrord_dir = Lagrange.interface_directory(Lagrange::Interface::Mirrord::INTERFACE_NAME)
native_file = Lagrange.data_file(mirrord_dir, "#{import_set}.yml")
Lagrange.ensure_clean(native_file)

Mirrored::Base.establish_connection(:delicious, username, password)
last_update_stamp = Mirrored::Update.last
tags=Mirrored::Tag.find(:get).map { |tag| tag.name }.sort
posts=Mirrored::Post.find(:all).map do |post|
  cleansed_url = Lagrange::DataTypes::URLs.cleanup(post.href).to_s
  {
    url: post.href,
    cleansed_url: cleansed_url,
    uuid: Lagrange::DataTypes::URLs.uuid(cleansed_url),
    description: post.description,
    extended: post.extended,
    others: post.others,
    tags: post.tags,
    created_at: post.time,
    mirrord_uuid: post.hash,
  }
end.sort { |a, b| a[:uuid] <=> b[:uuid] }

Lagrange.logger.info "Server Reports Last Update: #{last_update_stamp.strftime("%Y-%m-%d %H:%M:%S %z")}"
Lagrange.logger.info "Found #{tags.count} tags, and #{posts.count} posts."

File.open(native_file.absolute, "w") do |f|
  f.write({
    last_update: last_update_stamp,
    tags: tags,
    posts: posts,
  }.to_yaml)
end

Lagrange::snapshot(native_file, cli)
