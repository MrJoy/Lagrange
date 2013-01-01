#!/usr/bin/env ruby
LAGRANGE_PATH = File.expand_path('../../../',  __FILE__)
require File.expand_path("#{LAGRANGE_PATH}/lib/lagrange")
Lagrange.init!('safari')


cli = Lagrange::CLI.new(__FILE__)

IMPORT_OPTIONS=["-i <name>", "--import=<name>"]
cli.add_option_with_help(
  IMPORT_OPTIONS,
  "Import the specified Safari bookmark set to the native format.  If this option is ommitted, then Lagrange will use the default set named '#{Lagrange::Interface::Safari::DEFAULT_DATASET}.xml'.",
)

ALIAS_OPTIONS=["-a <name>", "--as=<name>"]
cli.add_option_with_help(
  ALIAS_OPTIONS,
  "Save the data under the name repo/#{Lagrange::Interface::Safari::INTERFACE_NAME}/<name>.yml.  Defaults to '#{Lagrange::Interface::Safari::DEFAULT_DATASET}.yml'."
)

cli.add_usage_form({ optional: [IMPORT_OPTIONS, ALIAS_OPTIONS] })

exit(1) unless(cli.parse_options(ARGV))
OPTIONS = cli.options
import_from = (!OPTIONS[:import].blank?) ? OPTIONS[:import] : Lagrange::Interface::Safari::DEFAULT_DATASET
import_to = (!OPTIONS[:as].blank?) ? OPTIONS[:as] : Lagrange::Interface::Safari::DEFAULT_DATASET

safari_dir = Lagrange.interface_directory(Lagrange::Interface::Safari::INTERFACE_NAME)
filename_tmp=File.join(safari_dir.absolute, "#{import_from}.xml")
raise "Specified dataset does not exist: #{import_from}.xml" if(!File.exists?(filename_tmp))
data_file = Lagrange.data_file(safari_dir, "#{import_from}.xml")
Lagrange.ensure_clean(data_file)
native_file = Lagrange.data_file(safari_dir, "#{import_to}.yml")
Lagrange.ensure_clean(native_file)

raw_data = File.readlines(filename_tmp).join('')
plist_data = Plist::parse_xml(raw_data)

def transform_bookmark(bookmark)
  case bookmark["WebBookmarkType"]
  when "WebBookmarkTypeProxy"
    return nil
  when "WebBookmarkTypeList"
    children_raw = bookmark["Children"].
      map { |c| transform_bookmark(c) }.
      reject { |b| b.nil? }
    children = []
    children_raw.each_with_index do |child,idx|
      child[:safari_position] = idx
      children << child
    end
    return {
      title: bookmark["Title"],
      safari_uuid: bookmark["WebBookmarkUUID"],
      children: children.sort { |a,b| (a[:uuid] || a[:safari_uuid]) <=> (b[:uuid] || b[:safari_uuid]) },
    }
  when "WebBookmarkTypeLeaf"
    url_tmp=Lagrange::DataTypes::URLs.cleanup(bookmark["URLString"]).to_s rescue nil
    if(url_tmp.nil?)
      STDERR.puts("Skipping invalid bookmark for UUID #{bookmark["WebBookmarkUUID"]}: #{bookmark["URLString"]}")
    else
      cleansed_url = Lagrange::DataTypes::URLs.cleanup(bookmark["URLString"]).to_s
      return {
        title: bookmark["URIDictionary"]["title"],
        url: bookmark["URLString"],
        cleansed_url: cleansed_url,
        uuid: Lagrange::DataTypes::URLs.uuid(cleansed_url),
        safari_uuid: bookmark["WebBookmarkUUID"],
      }
    end
  else
    raise "Unknown bookmark type: #{bookmark["WebBookmarkType"]}"
  end
end

if(plist_data["WebBookmarkFileVersion"]==1 &&
   plist_data["WebBookmarkType"]=="WebBookmarkTypeList" &&
   plist_data["WebBookmarkUUID"]=="Root")
  bookmarks = plist_data["Children"].
    map { |c| transform_bookmark(c) }.
    reject { |b| b.nil? }
  bookmarks.each_with_index do |bookmark, idx|
    bookmark[:safari_position] = idx
  end
  bookmarks = bookmarks.sort { |a,b| (a[:uuid] || a[:safari_uuid]) <=> (b[:uuid] || b[:safari_uuid]) }

  File.open(native_file.absolute, "w") { |f| f.write(bookmarks.to_yaml) }

  Lagrange::snapshot(native_file, cli)
else
  raise("Don't know how to handle this Safari bookmark file!")
end
