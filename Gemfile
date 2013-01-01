source :gemcutter

###############################################################################
# General Tools
###############################################################################
gem 'activesupport', require: false
gem 'clint',         require: false


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
gem 'plist',    require: false
# See this for info relevant to parsing binary plists natively:
# https://gist.github.com/303378

# Syncing Contacts:
gem 'contacts', require: false
#   https://github.com/mislav/contacts
#   https://github.com/pengwynn/linkedin

# Syncing Links:
#   https://github.com/weppos/www-delicious (We're not dealing with "bundles" right now!)
#   https://rubygems.org/gems/delicious-cli
gem 'mirrored', require: false # ... Magnolia is dead, but pinboard uses Mirror'd ...

#   https://github.com/philnash/bitly (Unfold bit.ly links...)
#   https://rubygems.org/gems/tagometer (Suggest tags...)


###############################################################################
# Development Infrastructure
###############################################################################
gem 'rake',           groups: [:development],        require: false
gem 'mg',             groups: [:development],        require: false
gem 'yard',           groups: [:development],       require: false, platform: :mri_19
gem 'yard-cucumber',  groups: [:development],       require: false, platform: :mri_19
gem 'kramdown',       groups: [:development],       require: false, platform: :mri_19
gem 'pry',            groups: [:development, :test]


###############################################################################
# Test Infrastructure
###############################################################################
gem 'rspec',              group: [:test], require: false
gem 'simplecov',          group: [:test], require: false
gem 'cucumber',           group: [:test], require: false
