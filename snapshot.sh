#!/bin/bash

bin/pinboard/import.rb --user="$PINBOARD_USER" --password="$PINBOARD_PASSWORD"
bin/delicious/import.rb --user="$DELICIOUS_USER" --password="$DELICIOUS_PASSWORD"
#bin/safari/pull.rb --go
#bin/safari/import.rb --go
