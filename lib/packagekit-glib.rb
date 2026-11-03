# frozen_string_literal: true

# Released under the Apache License, Version 2.0.
# Copyright, 2026, by General Intelligence Systems.

# `require "packagekit-glib"` — the gem's own name.
#
# This file exists because the gem name contains a dash and the library does
# not: the code lives in lib/packagekit_glib.rb, named for the PackageKitGlib namespace it
# defines. Without this, `require "packagekit-glib"` fails with
# `cannot load such file -- packagekit-glib`, which is how a port consuming this gem
# first discovered the problem.
#
# RubyGems also treats a dash as a directory separator, so gem_kit infers a
# require path of "packagekit/glib" from the gem name and warns
# "deprecations will not be detected" when nothing answers it. This file
# settles both.
require_relative "packagekit_glib"
