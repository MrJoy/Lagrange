#!/usr/bin/env ruby
LAGRANGE_PATH = File.expand_path('../../../',  __FILE__)
require File.expand_path("#{LAGRANGE_PATH}/lib/lagrange")
Lagrange.init!('safari')


Lagrange::CLI.toolname = __FILE__

options = ["-i <name>", "--import=<name>"]
Lagrange::CLI.add_usage_form("[#{options.join('|')}]")
Lagrange::CLI.add_help_for_option(
  options,
  "Import the specified Safari bookmark set to the native format.  If this option is ommitted, then Lagrange will use the default set named '#{Lagrange::Safari::MODULE_NAME}'.",
)
Lagrange::CLI.clint.options import: String, i: :import

Lagrange::CLI.parse_options

import_set = (Lagrange::CLI.clint.options[:import] != "") ? Lagrange::CLI.clint.options[:import] : Lagrange::Safari::DEFAULT_DATASET

safari_dir = Lagrange.module_directory(Lagrange::Safari::MODULE_NAME)
filename_tmp=File.join(safari_dir.absolute, "#{import_set}.xml")
raise "Specified dataset does not exist: #{import_set}" if(!File.exists?(filename_tmp))
data_file = Lagrange.data_file(safari_dir, "#{import_set}.xml")
Lagrange.ensure_clean(data_file)
native_file = Lagrange.data_file(safari_dir, "#{import_set}.yml")
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

  Lagrange::snapshot(native_file)
else
  raise("Don't know how to handle this Safari bookmark file!")
end
