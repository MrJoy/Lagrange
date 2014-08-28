ruby '2.1.2'
#ruby=ruby-2.1.2
#ruby-gemset=lagrange

source 'https://rubygems.org'

###############################################################################
# General Tools
###############################################################################
gem 'activesupport', require: false
gem 'clint',         require: false # TODO: Use Thor?
gem 'dotenv',        require: false # TODO: Ideal way to allow users to use this?



###############################################################################
# Core Data Model Tools
###############################################################################
gem 'rugged',         require: false
gem 'virtus',         require: false
gem 'dm-validations', require: false
gem 'addressable',    require: false
gem 'yajl-ruby',      require: false # Using YAJL for pretty-printing...



###############################################################################
# Data Pipeline Tools
###############################################################################

## File-type Detection / Parsing
#
# * http://rubygems.org/gems/file_classify
# * [Native parsing of binary plists](https://gist.github.com/303378)
gem 'plist',      require: false
gem 'osx-plist',  require: false

## Contacts
#
# * https://github.com/cardmagic/contacts -- Note, github is WAY newer than release!
#     * AOL
#     * Hotmail
#     * Yahoo
#     * Gmail
#     * Mail.ru
#     * Plaxo
# * https://github.com/mislav/contacts
#     * Flickr
#     * Google
#     * Windows Live!
#     * Yahoo
# * https://github.com/hexgnu/linkedin
#     * LinkedIn
# * https://github.com/bobbrez/linkedin2
#     * LinkedIn
# * TODO: Find handlers for the following services/apps...
#     * AngelList
#     * InstaGram
#     * Twitter
#     * Facebook
#     * FourSquare
#     * iCloud
#     * FullContact
#     * Skype
#     * Adium


## Links/Bookmarks

### Browser Bookmarks
#
# * [Safari](http://rubygems.org/gems/safari_plist)
# * [Firefox](https://github.com/lkdjiin/bookmarks)
# * [Chrome](http://rubygems.org/gems/bookmarkeron)

### Bookmark Services
# * [Readability](https://github.com/29decibel/readit)
# * [Delicious](https://rubygems.org/gems/delicious) -- Use this one!
# * [Delicious - CLI](https://rubygems.org/gems/delicious-cli)
# * [Delicious - Console Recorder](https://rubygems.org/gems/delicious-console)
# * [Pinboard - CLI](https://rubygems.org/gems/pinboard-cli)
gem 'mirrored',       require: false # TODO: Replace with `delicious` gem!
gem 'pinboard',       require: false # TODO: Upstream has un-released fixes in git: https://github.com/ryw/pinboard/
gem 'pinboard_tools', require: false

### Tagging/Classification
#
# * [uClassify](http://www.uclassify.com/browse/uClassify/Topics) -- [gem](http://rubygems.org/gems/uclassify)
# * https://rubygems.org/gems/tagometer

### URL Canonicalization / Cleansing / Short-Link Expansion
#
# * [Unfold Bit.ly Links](https://github.com/philnash/bitly)
# * http://citizen428.github.com/unsavory/

### Snapshotting
#
# * https://github.com/TransparencyToolkit/Archiver

## Other Data
#
# * [LinkedIn - Profile](https://github.com/yatish27/linkedin-scraper)
# * [LinkedIn - Profile](https://github.com/transparencytoolkit/linkedindata)
# * [LinkedIn - Resume](https://github.com/mefellows/linkedin2cv)
# * [Correlate Name to Email](https://github.com/TransparencyToolkit/NameToEmail)



###############################################################################
# Development Infrastructure
###############################################################################
gem 'rake',           groups: [:development],       require: false
gem 'yard',           groups: [:development],       require: false
gem 'kramdown',       groups: [:development],       require: false
gem 'pry',            groups: [:development, :test]


###############################################################################
# Test Infrastructure
###############################################################################
gem 'rspec',              group: [:test],         require: false
gem 'simplecov',          group: [:test],         require: false
gem 'cucumber',           group: [:test],         require: false
