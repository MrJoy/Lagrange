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
  delete: {
    params: ["--delete"],
    message: "Delete the import file if, and only if it is successfully imported."
  },
  snapshot: {
    params: ["-s", "--snapshot"],
    message: "Perform a commit of the specified dataset, without having to import anything.  Handy after importing many webloc/ftploc files using --defer."
  }
})

cli.add_usage_form(:import, {
  required: [:import],
  optional: [:as, :defer, :delete],
})

cli.add_usage_form(:snapshot, {
  required: [:snapshot],
  optional: [:as],
})

exit(1) unless(cli.parse_options(ARGV))
OPTIONS = cli.options

misc_dir = Lagrange.interface_directory(Lagrange::Interface::MiscURL::INTERFACE_NAME)
data_file = Lagrange.data_file(misc_dir, "#{OPTIONS[:as]}.json")

case cli.usage_form
when :import
  import_file = OPTIONS[:import]

  import_file = Lagrange.raw_file(import_file)
  raise "Specified file does not exist: #{import_file.absolute}" if(!File.exists?(import_file.absolute))

  additions = []

  Lagrange.logger.info("Reading #{import_file.absolute}...")
  if(import_file.absolute =~ /\.(webloc|ftploc)$/)
    additions << Lagrange::FileTypes::Webloc.read(import_file.absolute)
  else
    additions += File.readlines(import_file.absolute).map { |line| line.chomp }
  end

  Lagrange.ensure_clean(data_file) unless(OPTIONS[:defer])

  if(File.exist?(data_file.absolute))
    current_data = Lagrange::FileTypes::JSON.read(data_file.absolute)
  else
    current_data = []
  end

  # Don't count (effectively) blank lines as "invalid"...
  additions = additions.reject { |line| line.strip == "" }

  raw_count = additions.count
  additions = additions.
    map { |line| line.strip }.
    map { |line| (Lagrange::DataTypes::URLs.parse(line) rescue nil) }.
    reject { |uri| uri.nil? || uri.scheme.nil? }.
    map { |uri| uri.to_s }

  if(raw_count != additions.count)
    Lagrange.logger.warn("Not adding #{raw_count-additions.count} records out of #{raw_count} due to lack of well-formedness!")
    OPTIONS[:delete] = false
  end

  additions = additions.map do |a_url|
    cleansed_url = Lagrange::DataTypes::URLs.cleanup(a_url).to_s
    {
      url: a_url,
      cleansed_url: cleansed_url,
      uuid: Lagrange::DataTypes::URLs.uuid(cleansed_url),
    }
  end

  # TODO: We should probably support some semblence of updating as well...
  current_urls = Set.new(current_data.map { |bookmark| bookmark[:cleansed_url] })
  creates = additions.reject { |bookmark| current_urls.include?(bookmark[:cleansed_url]) }
  if(additions.count != creates.count)
    Lagrange.logger.warn("Not adding #{additions.count-creates.count} duplicate URLs out of #{additions.count}!")
  end

  current_data += creates
  current_data = current_data.sort { |a, b| a[:uuid] <=> b[:uuid] }

  File.open(data_file.absolute, "w") do |f|
    f.write(Lagrange::FileTypes::JSON.synthesize(current_data))
  end

  File.unlink(import_file.absolute) if(OPTIONS[:delete])

  Lagrange::snapshot(data_file, cli) unless(OPTIONS[:defer])

when :snapshot
  Lagrange::snapshot(data_file, cli)
end
