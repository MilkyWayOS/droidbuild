#!/usr/bin/env ruby
# frozen_string_literal: true

# This script is intended to be used ONLY inside of docker container.

$LOAD_PATH << "/opt/droid/buildroot"
$LOAD_PATH << "/opt/droid/lib/droidbuild"
$LOAD_PATH << "."

require 'droidbuild'

exit(main(ARGV))