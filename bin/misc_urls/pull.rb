#!/usr/bin/env ruby
# TODO: Support for importing multiple webloc/ftploc files at once.
# TODO: Use filename of webloc/ftploc files as link name.
# TODO: Use ctime/mtime of files for bookmarking time?
# TODO: Ensure DeRez is available, and kvetch if not (only when we need it of course).
LAGRANGE_PATH = File.expand_path('../../../',  __FILE__)
require File.expand_path("#{LAGRANGE_PATH}/lib/lagrange")
Lagrange.init!('misc_urls')

cli = Lagrange::CLI.new(__FILE__)

cli.add_options_with_help({
  import: {
    params: ["-i <file>", "--import=<file>"],
    message: "Import the specified OSX webloc/ftploc file, or text file.  If the file is a text file, it is presumed to contain one URL per line.",
  },
  as: {
    params: ["-a <name>", "--as=<name>"],
    message: "Save the data under the name repo/#{Lagrange::Interface::MiscURL::INTERFACE_NAME}/<name>.json.  Defaults to '#{Lagrange::Interface::MiscURL::DEFAULT_DATASET}'.",
    default: Lagrange::Interface::MiscURL::DEFAULT_DATASET,
  },
  defer: {
    params: ["-d", "--defer"],
    message: "Don't check to ensure dataset is clean, and don't commit after modifying.  Handy when importing many webloc/ftploc files.  Be sure to use --snapshot afterwards though.",
  },
  snapshot: {
    params: ["-s", "--snapshot"],
    message: "Perform a commit of the specified dataset, without having to import anything.  Handy after importing many webloc/ftploc files using --defer."
  }
})

cli.add_usage_form(:import, {
  required: [:import],
  optional: [:as, :defer],
})

cli.add_usage_form(:snapshot, {
  required: [:snapshot],
  optional: [:as],
})

exit(1) unless(cli.parse_options(ARGV))
OPTIONS = cli.options

case cli.usage_form
when :import
  Lagrange::Interface::MiscURL.import(OPTIONS[:import], OPTIONS[:as], OPTIONS[:defer], cli.toolname)
when :snapshot
  Lagrange::Interface::MiscURL.snapshot(OPTIONS[:as], cli.toolname)
end
