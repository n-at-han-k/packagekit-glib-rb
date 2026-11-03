# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.1] - 2026-11-03

### Fixed

- `require "packagekit-glib"` now works. The gem name contains a dash and the library
  does not, so the entry point was only reachable as `require "packagekit_glib"` and the
  gem's own name failed with `cannot load such file -- packagekit-glib`. Found the way it
  should be: a port added this gem as a dependency and could not load it. Both
  the gem name and the nested path RubyGems infers from a dash now resolve.

## [1.0.0] - 2026-11-03

### Fixed

- `require "packagekit-glib"` now works. The gem name contains a dash and the library
  does not, so the entry point was only reachable under its underscored name
  and `require "packagekit-glib"` failed with `cannot load such file -- packagekit-glib`. Found by
  a port that depended on this gem and could not load it. Both the gem's own
  name and the nested path RubyGems infers from a dash now resolve.

