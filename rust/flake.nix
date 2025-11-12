# Flake for a Rust application. To use:
# - change `description` below
# - change `name`, `version`, `description` in the flake itself
# - update Cargo.toml
# Notably, the description can't be set with one variable,
# because flakes are an odd subset of Nix.
# https://github.com/NixOS/nix/issues/4945
#
# For your convenience, each variable across all files is named
# in SCREAMING_SNAKE_CASE.
{
  description = "APPLICATION_DESCRIPTION";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        name = "APPLICATION_NAME";
        version = "APPLICATION_VERSION";
        description = "APPLICATION_DESCRIPTION";

        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
            "llvm-tools-preview"
          ];
        };

        nativeBuildInputs = with pkgs; [
          rustToolchain
          pkg-config
          just
          cargo-llvm-cov
        ];

        buildInputs =
          with pkgs;
          [
            # any other build inputs go here
          ]
          ++ lib.optionals stdenv.isDarwin [
            darwin.apple_sdk.frameworks.Security
            darwin.apple_sdk.frameworks.CoreFoundation
          ];

      in
      {
        devShells.default = pkgs.mkShell {
          inherit nativeBuildInputs buildInputs;
        };

        packages.default = pkgs.rustPlatform.buildRustPackage {
          inherit version nativeBuildInputs buildInputs;
          pname = name;

          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;

          meta = {
            inherit description;
            license = pkgs.lib.licenses.mit;
            maintainers = [ ];
          };
        };

        packages.${name} = self.packages.${system}.default;
      }
    );
}
