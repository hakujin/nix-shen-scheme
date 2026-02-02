{
  description = "A Scheme port of the Shen language";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        shen-scheme = pkgs.callPackage ./package.nix { };
      in {
        packages = {
          default = shen-scheme;
          shen-scheme = shen-scheme;
        };

        apps.default = {
          type = "app";
          program = "${shen-scheme}/bin/shen-scheme";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            chez
            lz4
            zlib
          ] ++ pkgs.lib.optional pkgs.stdenv.isLinux pkgs.libuuid;

          shellHook = ''
            echo "Shen Scheme development environment"
            echo "Chez Scheme version: ${pkgs.chez.version}"
          '';
        };
      });
}
