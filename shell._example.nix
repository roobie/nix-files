# See more at
# https://nixos.org/nix/manual/#sec-nix-shell
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell rec {
  buildInputs = [
    pkgs.gnumake
    pkgs.autoconf
    pkgs.gcc
    pkgs.chibi
  ];
}
