module Lagrange
  module Safari
    DEFAULT_BOOKMARKS_PATH_RAW="~/Library/Safari/Bookmarks.plist".freeze
    DEFAULT_BOOKMARKS_PATH=File.expand_path(DEFAULT_BOOKMARKS_PATH_RAW).freeze
    DEFAULT_DATASET="safari".freeze
    MODULE_NAME="safari"
  end
end
