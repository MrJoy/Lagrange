#!/usr/bin/env ruby
LAGRANGE_PATH = File.expand_path('../../../',  __FILE__)
require File.expand_path("#{LAGRANGE_PATH}/lib/lagrange")
Lagrange.init!('pinboard')


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
    message: "Save the data under the name repo/#{Lagrange::Interface::Pinboard::INTERFACE_NAME}/<name>.json.  Defaults to '#{Lagrange::Interface::Pinboard::DEFAULT_DATASET}'.",
  },
})

cli.add_usage_form(:default, { required: [:user, :password], optional: [:as] })

exit(1) unless(cli.parse_options(ARGV))
OPTIONS = cli.options

case cli.usage_form
when :default
  username = OPTIONS[:user].downcase
  password = OPTIONS[:password]
  import_set = (OPTIONS[:as] != "") ? OPTIONS[:as] : Lagrange::Interface::Pinboard::DEFAULT_DATASET

  pinboard_dir = Lagrange.interface_directory(Lagrange::Interface::Pinboard::INTERFACE_NAME)
  native_file = Lagrange.data_file(pinboard_dir, "#{import_set}.json")
  Lagrange.ensure_clean(native_file)

  posts = Pinboard::Post.all(username: username, password: password)
  tags = Set.new
  posts = posts.map do |post|
    cleansed_url = Lagrange::DataTypes::URLs.cleanup(post.href).to_s
    tags += post.tag
    {
      url: post.href,
      cleansed_url: cleansed_url,
      uuid: Lagrange::DataTypes::URLs.uuid(cleansed_url),
      description: post.description,
      tags: post.tag,
      created_at: post.time.to_datetime.utc,
      pinboard_uuid: post.hash,
    }
  end.sort { |a, b| a[:uuid] <=> b[:uuid] }

  Lagrange.logger.info "Found #{tags.count} tags, and #{posts.count} posts."

  File.open(native_file.absolute, "wb") do |f|
    f.write(Lagrange::FileTypes::JSON.synthesize(posts))
  end

  Lagrange::snapshot(native_file, cli.toolname)
end
