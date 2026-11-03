# frozen_string_literal: true

# Released under the Apache License, Version 2.0.
# Copyright, 2026, by General Intelligence Systems.

require "packagekit_glib"

describe PackageKitGlib do
  it "defines the namespace from the typelib" do
    # Not an arbitrary number: it is the point of the loader. A hand-written
    # binding exposes what someone got round to wrapping; this exposes what the
    # library has. A drop to single digits means the loader half-ran.
    expect(PackageKitGlib.constants.size).to be > 5
  end

  it "maps methods onto classes, not just constants" do
    # A loader that registered the types but no methods would still satisfy a
    # constant count, so this is the assertion that catches it.
    klass = PackageKitGlib.constants
      .map {|name| PackageKitGlib.const_get(name) }
      .grep(Class)
      .find {|c| (c.instance_methods - Object.instance_methods).any? }

    expect(klass).not.to be_nil
  end

  it "loads classes that descend from GObject" do
    # The typelib describes GObject types, so what the loader produces should be
    # GLib::Object subclasses rather than bare Ruby classes.
    descendants = PackageKitGlib.constants
      .map {|name| PackageKitGlib.const_get(name) }
      .grep(Class)
      .select {|c| c.ancestors.include?(GLib::Object) }

    expect(descendants).not.to be(:empty?)
  end
end
