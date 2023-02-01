{
  description = "Run a command until it succeeds";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    crane = {
      url = "github:ipetkov/crane";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        rust-overlay.follows = "rust-overlay";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
    crane,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (import rust-overlay)
        ];
      };

      rustToolchain = pkgs.rust-bin.stable.latest;
      craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain.minimal;
    in {
      packages = rec {
        pwease = craneLib.buildPackage {
          src = craneLib.cleanCargoSource ./.;
        };

        default = pwease;
      };

      devShells.default = pkgs.mkShell {
        packages = [
          rustToolchain.default
        ];

        shellHook = ''
          rustc --version
        '';
      };

      formatter = pkgs.alejandra;
    });
}
