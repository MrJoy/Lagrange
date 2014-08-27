#!/bin/bash

bin/pinboard/import.rb --user="$PINBOARD_USER" --password="$PINBOARD_PASSWORD"
bin/delicious/import.rb --user="$DELICIOUS_USER" --password="$DELICIOUS_PASSWORD"
bin/safari/pull.rb --go
bin/safari/import.rb --go

# pinboard_tools safari [-v]
# Runs the Safari Reading List import to Pinboard task. This will parse your
# Reading List plist file, extract resolvable URLs, use Embedly to determine
# the correct metadata, and add each item to Pinboard. Once complete, it will
# clear out the Reading List to prevent duplicate tasks and minimize future
# Embedly API usage.

# pinboard_tools tag [optional tag name] [-v]
# Runs the pinboard re-tagger task. When run without a tag name, it will
# process every article you saved to Pinboard. If you specify a tag (case
# sensitive), it will process every article that has that tag, and replace the
# metadata of the item with Embedly data.

# Adding the -v option to either command will display a progress bar for the
# parsing queue.
