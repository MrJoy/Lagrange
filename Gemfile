ruby '2.1.2'
#ruby=ruby-2.1.2
#ruby-gemset=lagrange

source 'https://rubygems.org'

###############################################################################
# General Tools
###############################################################################
gem 'activesupport', require: false
gem 'clint',         require: false # TODO: Use Thor?
gem 'dotenv',        require: false


###############################################################################
# Core Data Model Tools
###############################################################################
gem 'grit',           require: false
gem 'virtus',         require: false
gem 'dm-validations', require: false
gem 'addressable',    require: false
gem 'yajl-ruby',      require: false # Using YAJL for pretty-printing...


###############################################################################
# Data Pipeline Tools
###############################################################################
gem 'plist',      require: false
gem 'osx-plist',  require: false
# See this for info relevant to parsing binary plists natively:
# https://gist.github.com/303378

# Syncing Contacts:
gem 'contacts',   require: false
#   https://github.com/mislav/contacts
#   https://github.com/pengwynn/linkedin

# Syncing Links:
#   https://github.com/weppos/www-delicious (We're not dealing with "bundles" right now!)
#   https://rubygems.org/gems/delicious-cli
#   https://github.com/29decibel/readit
gem 'mirrored',   require: false # ... Magnolia is dead, but pinboard uses Mirror'd ...
gem 'pinboard',   require: false

#   https://github.com/philnash/bitly (Unfold bit.ly links...)
#   https://rubygems.org/gems/tagometer (Suggest tags...)
#   http://citizen428.github.com/unsavory/ (Finding stale links...)


###############################################################################
# Development Infrastructure
###############################################################################
gem 'rake',           groups: [:development],       require: false
gem 'yard',           groups: [:development],       require: false
gem 'yard-cucumber',  groups: [:development],       require: false
gem 'kramdown',       groups: [:development],       require: false
gem 'pry',            groups: [:development, :test]


###############################################################################
# Test Infrastructure
###############################################################################
gem 'rspec',              group: [:test], require: false
gem 'simplecov',          group: [:test], require: false
gem 'cucumber',           group: [:test], require: false
