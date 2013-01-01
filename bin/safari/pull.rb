#!/usr/bin/env ruby
LAGRANGE_PATH = File.expand_path('../../../',  __FILE__)
require File.expand_path("#{LAGRANGE_PATH}/lib/lagrange")
Lagrange.init!('safari')


cli = Lagrange::CLI.new(__FILE__)

cli.add_options_with_help({
  go: {
    params: ["-g", "--go"],
    message: "Actually perform the import."
  },
  import: {
    params: ["-i <plist>", "--import=<plist>"],
    message: [
      "Import the specified Safari bookmarks file.  If this option is ommitted, then Lagrange will look for bookmarks here:",
      Lagrange::Interface::Safari::DEFAULT_BOOKMARKS_PATH_RAW
    ],
  },
  as: {
    params: ["-a <name>", "--as=<name>"],
    message: "Save the data under the name repo/#{Lagrange::Interface::Safari::INTERFACE_NAME}/<name>.xml.  Defaults to '#{Lagrange::Interface::Safari::DEFAULT_DATASET}'.",
  },
})

cli.add_usage_form({ required: [:go], optional: [:import, :as] })

exit(1) unless(cli.parse_options(ARGV))
OPTIONS = cli.options
exit unless(OPTIONS[:go])

import_file = (!OPTIONS[:import].blank?) ? OPTIONS[:import] : Lagrange::Interface::Safari::DEFAULT_BOOKMARKS_PATH
import_as = (!OPTIONS[:as].blank?) ? OPTIONS[:as] : Lagrange::Interface::Safari::DEFAULT_DATASET

raise "Specified file does not exist: #{import_file}" if(!File.exists?(import_file))

raw_data = `plutil -convert xml1 -o - -s #{import_file.shellescape}`

safari_dir = Lagrange.interface_directory(Lagrange::Interface::Safari::INTERFACE_NAME)
data_file = Lagrange.data_file(safari_dir, "#{import_as}.xml")

Lagrange.ensure_clean(data_file)

File.open(data_file.absolute, "w") do |f|
  f.write(raw_data)
end

Lagrange::snapshot(data_file, cli)
