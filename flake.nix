{
  description = "packagekit_glib — Ruby bindings";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    mine.url = "github:n-at-han-k/flake.nix";
    mine.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, mine, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = mine.lib.${system};

        gemspecFiles = pkgs.runCommand "packagekit_glib-gemspec" { } ''
          mkdir -p $out/lib/packagekit_glib
          cp ${./packagekit-glib.gemspec}         $out/packagekit-glib.gemspec
          cp ${./lib/packagekit_glib/version.rb}  $out/lib/packagekit_glib/version.rb
        '';

        gems = pkgs.bundlerEnv {
          name = "packagekit_glib-gems";
          ruby = pkgs.ruby_3_4;
          gemfile = ./Gemfile;
          lockfile = ./Gemfile.lock;
          gemset = import ./gemset.nix;
          extraConfigPaths = [ "${gemspecFiles}/." ];
        };

        # The namespaces the loader needs at require time: PackageKitGlib itself, and
        # Gio/GLib/GObject which PackageKitGlib-1.0.typelib declares as dependencies and
        # the loader resolves transitively.
        #
        # `makeSearchPath` would take each package's *first* output, and glib's
        # first output is `bin`, which carries no typelibs -- hence the explicit
        # `.out`. This is the same trap the port scaffold documents.
        typelibPath = pkgs.lib.makeSearchPath "lib/girepository-1.0"
          (map (drv: drv.out or drv) [ pkgs.packagekit pkgs.glib ]);
      in
      {
        devShells.default = lib.mkRubyShell {
          buildInputs = with pkgs; [
            gems
            gems.wrappedRuby

            # packagekit itself, for its typelib. Taking it from the same
            # nixpkgs as the gobject-introspection gem is not a tidiness
            # point: a typelib built against a different glib registers GIO a
            # second time in the process and dies with
            #   cannot register existing type 'GTlsCertificate'
            packagekit

            skywalking-eyes
          ];

          shellHook = /* bash */ ''
            # PackageKitGlib-1.0.typelib and the typelibs it declares, which the loader
            # resolves transitively at require time. A missing one surfaces as
            # "Typelib file for namespace 'X' not found", one at a time.
            export GI_TYPELIB_PATH="${typelibPath}''${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"

            export BUNDLE_GEMFILE="$PWD/Gemfile"
            export BUNDLE_FROZEN=false

            export LANG="''${LANG:-C.UTF-8}"
            export LC_ALL="''${LC_ALL:-$LANG}"

            export RUBYLIB="$PWD/lib''${RUBYLIB:+:$RUBYLIB}"
          '';
        };
      }
    );
}
