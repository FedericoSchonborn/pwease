{
  description = "Run a command until it succeeds";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {nixpkgs, ...}: let
    forEachSystem = f: nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"] (system: f nixpkgs.legacyPackages.${system});
  in {
    packages = forEachSystem (pkgs: rec {
      pwease = pkgs.rustPlatform.buildRustPackage {
        pname = "pwease";
        version = "unstable";

        src = pkgs.nix-gitignore.gitignoreSource [] ./.;
        cargoLock.lockFile = ./Cargo.lock;
      };

      default = pwease;
    });

    devShells = forEachSystem (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          cargo
          rustc
        ];
      };
    });

    formatter = forEachSystem (pkgs: pkgs.alejandra);
  };
}
