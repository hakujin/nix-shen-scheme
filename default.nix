{ pkgs ? import <nixpkgs> {} }: {
    shen-scheme = pkgs.callPackage ./package.nix { };
}
