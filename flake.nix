{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-ruby.url = "github:bobvanderlinden/nixpkgs-ruby";
    nixpkgs-ruby.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-ruby,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      ruby = nixpkgs-ruby.lib.packageFromRubyVersionFile {
        file = ./.ruby-version;
        inherit system;
      };

      gems = pkgs.bundlerEnv {
        name = "gemset";
        inherit ruby;
        gemfile = ./Gemfile;
        lockfile = ./Gemfile.lock;
        gemset = ./gemset.nix;
        groups = ["default" "production" "development" "test"];
      };
    in {
      devShell = with pkgs;
        mkShell {
          nativeBuildInputs = with pkgs; [
            bashInteractive
            pkg-config
            autoreconfHook
            python313
            libjpeg
            libxslt
            doxygen
            graphviz
            isa-l
            zlib
          ];
          buildInputs = [
            # gems
            ruby
            bundix
            cacert
            libxml2
            openssl
            libxslt
            libffi
            udev
            ffmpeg
          ];
        };
    });
}
