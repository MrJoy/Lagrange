ruby '2.1.2'
#ruby=ruby-2.1.2
#ruby-gemset=lagrange

source 'https://rubygems.org'

###############################################################################
# General Tools
###############################################################################
gem 'activesupport', require: false
gem 'clint',         require: false # TODO: Use Thor; rake2thor may be of some help...
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
# * https://github.com/ypendharkar/XML-Contacts-Extractor
# * http://rubygems.org/gems/contact_sport
gem 'plist',      require: false
gem 'osx-plist',  require: false

## Keychain Access
#
# * https://github.com/seattlerb/osx_keychain

## Contacts
#
# * https://github.com/cardmagic/contacts -- Note, github is WAY newer than release!
#     * AOL
#     * Gmail
#     * Hotmail
#     * Mail.ru
#     * Plaxo
#     * Yahoo
# * https://github.com/mislav/contacts
#     * Flickr
#     * Google
#     * Windows Live!
#     * Yahoo
# * https://github.com/liangzan/contacts
#     * AOL
#     * Gmail
#     * GMX.net
#     * Hotmail
#     * inbox.it
#     * Plaxo
#     * sezname.cz
#     * Web.de
#     * Yahoo
# * http://rubygems.org/gems/googlecontacts
#     * Gmail
# * https://github.com/aliang/google_contacts_api
#     * Gmail
# * https://github.com/hexgnu/linkedin
#     * LinkedIn
# * https://github.com/bobbrez/linkedin2
#     * LinkedIn
# * https://github.com/Diego81/omnicontacts
#     * Facebook
#     * Gmail
#     * Hotmail
#     * Yahoo
# * https://github.com/paperlesspost/contacts
#     * AOL
#     * Gmail
#     * Hotmail
#     * Outlook
#     * Plaxo
#     * VCF
#     * Yahoo
# * https://github.com/boffbowsh/contact-list
#     * Facebook
#     * Gmail
#     * LinkedIn
#     * Twitter
#     * Yahoo
# * TODO: Find handlers for the following services/apps...
#     * Adium
#     * AngelList
#     * Facebook
#     * Facetime?
#     * FourSquare
#     * FullContact
#     * Github
#     * Google+
#     * iCloud
#     * InstaGram
#     * Klout
#     * Messages?
#     * MSN
#     * Skype
#     * Twitter
#     * Windows Live!
#     * Yahoo Messenger


## Links/Bookmarks

### Browser Bookmarks
#
# * [Safari](http://rubygems.org/gems/safari_plist)
# * [Firefox](https://github.com/lkdjiin/bookmarks)
# * [Chrome](http://rubygems.org/gems/bookmarkeron)

### Bookmark Services
#
# * [Readability](https://github.com/29decibel/readit)
# * [Delicious](https://rubygems.org/gems/delicious) -- Use this one!
# * [Delicious - CLI](https://rubygems.org/gems/delicious-cli)
# * [Delicious - Console Recorder](https://rubygems.org/gems/delicious-console)
# * [Pinboard - CLI](https://rubygems.org/gems/pinboard-cli)
gem 'mirrored',       require: false # TODO: Replace with `delicious` gem!
gem 'pinboard',       require: false # TODO: Upstream has un-released fixes in git: https://github.com/ryw/pinboard/
gem 'pinboard_tools', require: false

### Others To Find Solutions For
#
# * NewsRack
# * Pocket
# * Pulp
# * Read Later
# * ReadItLater
# * ReadKit
# * Reeder

### Tagging/Classification
#
# * [uClassify](http://www.uclassify.com/browse/uClassify/Topics) -- [gem](http://rubygems.org/gems/uclassify)
# * https://rubygems.org/gems/tagometer

### URL Canonicalization / Cleansing / Short-Link Expansion
#
# * [Unfold Bit.ly Links](https://github.com/philnash/bitly)
# * http://citizen428.github.com/unsavory/
# * Normalize Klout URLS -- http://klout.com/ezoic and http://klout.com/user/ezoic to https://klout.com/#/ezoic

### Snapshotting
#
# * https://github.com/TransparencyToolkit/Archiver

## Other Data
#
# * [LinkedIn - Profile](https://github.com/yatish27/linkedin-scraper)
# * [LinkedIn - Profile](https://github.com/transparencytoolkit/linkedindata)
# * [LinkedIn - Resume](https://github.com/mefellows/linkedin2cv)
# * [Correlate Name to Email](https://github.com/TransparencyToolkit/NameToEmail)
# * [FullContact Person API](https://github.com/fullcontact/fullcontact-api-ruby)
# * [Xenapto Contact Data](https://github.com/Xenapto/contact-data)
# * [Clearbit Contact Data](https://github.com/maccman/clearbit-ruby)
# * [Photo Similarity](https://github.com/maccman/dhash)
# * TODO: Find things for syncing between:
#     * Domainer
#     * Ehon
#     * EverNote
#     * Github
#     * Notes
#     * OmniFocus
#     * Reminders
#     * Things
#
# http://www.frostbox.com
# https://spideroak.com/
# https://www.sugarsync.com/sync_comparison.html
# https://tresorit.com
# https://zapier.com/zapbook/apps/
# https://persowna.net
# http://nymote.org
# http://semanticweb.org/wiki/Tools
# http://semanticweb.org/wiki/RDF.rb
#     https://github.com/ruby-rdf/rdf
# http://simile.mit.edu/wiki/Piggy_Bank
# http://www.kiwi-project.eu
# http://artificialmemory.net
# https://github.com/celsowm/AutoMeta#autometa
# https://code.google.com/p/knowee/
# http://www.know.ee



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
