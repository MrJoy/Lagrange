#!/usr/bin/env ruby
LAGRANGE_PATH = File.expand_path('../../../',  __FILE__)
require File.expand_path("#{LAGRANGE_PATH}/lib/boot")
require 'lagrange/safari/common'


Lagrange::toolname = __FILE__

options = ["-i <plist>", "--import=<plist>"]
Lagrange::add_usage_form("[#{options.join('|')}]")
Lagrange::add_help_for_option(
  options,
  [
    "Import the specified Safari bookmarks file.  If this option is ommitted, then Lagrange will look for bookmarks here:",
    Lagrange::Safari::DEFAULT_BOOKMARKS_PATH_RAW
  ]
)
Lagrange::clint.options import: String, i: :import

options = ["-a <name>", "--as=<name>"]
Lagrange::add_usage_form("[#{options.join('|')}]")
Lagrange::add_help_for_option(
  options,
  "Save the data under the name repo/#{Lagrange::Safari::MODULE_NAME}/<name>.xml.  Defaults to '#{Lagrange::Safari::DEFAULT_DATASET}'."
)
Lagrange::clint.options as: String, a: :as


Lagrange::parse_options

import_file = (Lagrange::clint.options[:import] != "") ? Lagrange::clint.options[:import] : Lagrange::Safari::DEFAULT_BOOKMARKS_PATH
import_as = (Lagrange::clint.options[:as] != "") ? Lagrange::clint.options[:as] : Lagrange::Safari::DEFAULT_DATASET

raise "Specified file does not exist: #{import_file}" if(!File.exists?(import_file))

raw_data = `plutil -convert xml1 -o - -s #{Shellwords.shellescape(import_file)}`

safari_dir = Lagrange::module_directory(Lagrange::Safari::MODULE_NAME)
data_file = Lagrange::data_file(safari_dir, "#{import_as}.xml")

Lagrange::ensure_clean(data_file)

File.open(data_file.absolute, "w") do |f|
  f.write(raw_data)
end

Lagrange::snapshot(data_file)
