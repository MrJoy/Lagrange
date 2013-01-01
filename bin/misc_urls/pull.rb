#!/usr/bin/env ruby
# TODO: Support for importing multiple webloc/ftploc files at once.
# TODO: Use filename of webloc/ftploc files as link name.
# TODO: Use ctime/mtime of files for bookmarking time?
# TODO: Ensure DeRez is available, and kvetch if not (only when we need it of course).
LAGRANGE_PATH = File.expand_path('../../../',  __FILE__)
require File.expand_path("#{LAGRANGE_PATH}/lib/lagrange")
Lagrange.init!('misc_urls')


Lagrange::CLI.toolname = __FILE__

options = ["-i <file>", "--import=<file>"]
Lagrange::CLI.add_usage_form("[#{options.join('|')}]")
Lagrange::CLI.add_help_for_option(
  options,
  "Import the specified OSX webloc/ftploc file, or text file.  If the file is a text file, it is presumed to contain one URL per line."
)
Lagrange::CLI.clint.options import: String, i: :import

options = ["-a <name>", "--as=<name>"]
Lagrange::CLI.add_usage_form("[#{options.join('|')}]")
Lagrange::CLI.add_help_for_option(
  options,
  "Save the data under the name repo/#{Lagrange::MiscURLs::MODULE_NAME}/<name>.json.  Defaults to '#{Lagrange::MiscURLs::DEFAULT_DATASET}'."
)
Lagrange::CLI.clint.options as: String, a: :as

options = ["-d", "--defer"]
Lagrange::CLI.add_usage_form("[#{options.join('|')}]")
Lagrange::CLI.add_help_for_option(
  options,
  "Don't check to ensure dataset is clean, and don't commit after modifying.  Handy when importing many webloc/ftploc files.  Be sure to use --snapshot afterwards though."
)
Lagrange::CLI.clint.options defer: false, d: :defer

options = ["-s", "--snapshot"]
Lagrange::CLI.add_usage_form("[#{options.join('|')}]")
Lagrange::CLI.add_help_for_option(
  options,
  "Perform a commit of the specified dataset, without having to import anything.  Handy after importing many webloc/ftploc files using --defer."
)
Lagrange::CLI.clint.options snapshot: false, s: :snapshot

options = ["--delete"]
Lagrange::CLI.add_usage_form("[#{options.join('|')}]")
Lagrange::CLI.add_help_for_option(
  options,
  "Delete the import file if, and only if it is successfully imported."
)
Lagrange::CLI.clint.options delete: false


Lagrange::CLI.parse_options
OPTIONS = Lagrange::CLI.clint.options

import_file = OPTIONS[:import]
import_as = (OPTIONS[:as] != "") ? OPTIONS[:as] : Lagrange::MiscURLs::DEFAULT_DATASET
defer = OPTIONS[:defer]
snapshot = OPTIONS[:snapshot]
delete = OPTIONS[:delete]

if(snapshot)
  raise "Can't use --import in conjunction with --snapshot." if(import_file != "")
  raise "Can't use --delete in conjunction with --snapshot." if(delete)
else
  raise "Must specify a file to import, use '-?' for usage." if(import_file == "")
  import_file = Lagrange.raw_file(import_file)
  raise "Specified file does not exist: #{import_file.absolute}" if(!File.exists?(import_file.absolute))
end

additions = []
unless(snapshot)
  STDERR.puts("Reading #{import_file.absolute}...")
  if(import_file.absolute =~ /\.(webloc|ftploc)$/)
    if(File.size(import_file.absolute) == 0)
      url = raw_resource_fork = `DeRez -e -only 'url ' #{import_file.absolute.shellescape} | fgrep '$"'`.
        split(/\n/).
        map { |line| line.gsub(/^[ \t]+\$"(.*?)".*$/, '\1').gsub(/([0-9A-F]{2})/, '\1 ').split(/\s+/) }.
        flatten.
        map { |hexcode| hexcode.to_i(16).chr }.
        join('').
        chomp
      if(url.nil? || url == "")
        raise "Couldn't retrieve URL from webloc/ftploc that appears to be storing it in the resource fork.  Do you have the developer tools installed?"
      end
      additions << url
    else
      raw_data = `plutil -convert xml1 -o - -s #{import_file.absolute.shellescape}`
      plist_data = Plist::parse_xml(raw_data)
      raise "Couldn't parse #{import_file.absolute}!" if(plist_data.nil?)
      unknown_keys = plist_data.keys - ["URL"]
      if(unknown_keys.count > 0)
        delete = false
        STDERR.puts("Got unknown keys in webloc: #{unknown_keys.join(', ')}")
      end
      raise "Couldn't find a URL in #{import_file.absolute}!" if(plist_data["URL"].nil? || plist_data["URL"] == "")
      additions << plist_data["URL"]
    end
  else
    additions += File.readlines(import_file.absolute).map { |line| line.chomp }
  end
end

misc_dir = Lagrange.module_directory(Lagrange::MiscURLs::MODULE_NAME)
data_file = Lagrange.data_file(misc_dir, "#{import_as}.json")

Lagrange.ensure_clean(data_file) unless(defer || snapshot)

unless(snapshot)
  if(File.exist?(data_file.absolute))
    current_data = MultiJson.load(File.read(data_file.absolute), symbolize_keys: true)
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
    STDERR.puts("Not adding #{raw_count-additions.count} records out of #{raw_count} due to lack of well-formedness!")
    delete = false
  end

  additions = additions.map do |url|
    cleansed_url = Lagrange::DataTypes::URLs.cleanup(url).to_s
    {
      url: url,
      cleansed_url: cleansed_url,
      uuid: Lagrange::DataTypes::URLs.uuid(cleansed_url),
    }
  end

  # TODO: We should probably support some semblence of updating as well...
  current_urls = Set.new(current_data.map { |bookmark| bookmark[:cleansed_url] })
  creates = additions.reject { |bookmark| current_urls.include?(bookmark[:cleansed_url]) }
  if(additions.count != creates.count)
    STDERR.puts("Not adding #{additions.count-creates.count} duplicate URLs out of #{additions.count}!")
    delete = false
  end

  current_data += additions
  current_data = current_data.sort { |a, b| a[:uuid] <=> b[:uuid] }

  File.open(data_file.absolute, "w") do |f|
    f.write(MultiJson.dump(current_data, pretty: true))
    f.write("\n")
  end
end

File.unlink(import_file.absolute) if(delete)

Lagrange::snapshot(data_file) unless(defer)