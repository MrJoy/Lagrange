#!/usr/bin/env ruby
LAGRANGE_PATH = File.expand_path('../../../',  __FILE__)
require File.expand_path("#{LAGRANGE_PATH}/lib/lagrange")
Lagrange.init!('safari')


Lagrange::CLI.toolname = __FILE__

IMPORT_OPTIONS=["-i <plist>", "--import=<plist>"]
Lagrange::CLI.add_option_with_help(
  IMPORT_OPTIONS,
  [
    "Import the specified Safari bookmarks file.  If this option is ommitted, then Lagrange will look for bookmarks here:",
    Lagrange::Interface::Safari::DEFAULT_BOOKMARKS_PATH_RAW
  ]
)

ALIAS_OPTIONS=["-a <name>", "--as=<name>"]
Lagrange::CLI.add_option_with_help(
  ALIAS_OPTIONS,
  "Save the data under the name repo/#{Lagrange::Interface::Safari::INTERFACE_NAME}/<name>.xml.  Defaults to '#{Lagrange::Interface::Safari::DEFAULT_DATASET}'."
)

Lagrange::CLI.add_usage_form({
  optional: [
    IMPORT_OPTIONS,
    ALIAS_OPTIONS,
  ]
})

Lagrange::CLI.parse_options

import_file = (Lagrange::CLI.clint.options[:import] != "") ? Lagrange::CLI.clint.options[:import] : Lagrange::Interface::Safari::DEFAULT_BOOKMARKS_PATH
import_as = (Lagrange::CLI.clint.options[:as] != "") ? Lagrange::CLI.clint.options[:as] : Lagrange::Interface::Safari::DEFAULT_DATASET

raise "Specified file does not exist: #{import_file}" if(!File.exists?(import_file))

raw_data = `plutil -convert xml1 -o - -s #{import_file.shellescape}`

safari_dir = Lagrange.interface_directory(Lagrange::Interface::Safari::INTERFACE_NAME)
data_file = Lagrange.data_file(safari_dir, "#{import_as}.xml")

Lagrange.ensure_clean(data_file)

File.open(data_file.absolute, "w") do |f|
  f.write(raw_data)
end

Lagrange::snapshot(data_file)
