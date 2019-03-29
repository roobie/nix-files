# NOTE(akavel): this file can be either a set, or a func (both are allowed).
{
  # allowUnfree = true;
  # TODO(akavel): set $EDITOR to vim
  packageOverrides = defaultPkgs: with defaultPkgs; {
    # NOTE(akavel): `pkgs` below contains "final" packages "from the future",
    # after all overrides. And `defaultPkgs` contains packages in "pristine"
    # state (before any of the following overrides were applied).

    # TODO investigate:
    # packageOverrides = pkgs: with pkgs; {
    # To install below "pseudo-package", run:
    #     $ nix-env -iA user-packages -f '<nixpkgs>'
    userPackages = buildEnv {
      name = "user-packages";
      inherit ((import <nixpkgs/nixos> {}).config.system.path)
      pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      paths = [
        # `anki` package at the version merged in https://github.com/NixOS/nixpkgs/pull/51272.
        (import (builtins.fetchGit {
          # Descriptive name to make the store path easier to identify
          name = "nixpkgs-pr-51272";
          url = https://github.com/nixos/nixpkgs/;
          rev = "33b9aa4f35fdc0220987c7f87c1204b5b76f21ad";
        }) {}).anki
        # `emacs` package at the version in the channel.
        emacs
        # Other packages at the channel version
      ];
    };

    # "Declarative user profile/config". Install:
    # `nix-env -iA nixos.home`
    home = with pkgs; buildEnv {

      name = "home";

      paths = [
        acpi
        alacritty
        # busybox
        clang
        curl
        emacs
        dotnet-sdk
        ffmpeg
        fira-code
        firefox
        fish
        fsharp
        git
        gnumake
        htop
        kitty
        ktorrent
        (lxappearance.overrideAttrs(old:
          rec {
            name = "lxappearance-0.6.2";
            src = fetchurl {
              url = "mirror://sourceforge/project/lxde/LXAppearance/${name}.tar.xz";
              sha256 = "07r0xbi6504zjnbpan7zrn7gi4j0kbsqqfpj8v2x94gr05p16qj4";
            };
          }))
        mono
        mpv
        neovim
        # pkg-config
        numix-cursor-theme
        psmisc
        qemu
        redshift
        ripgrep
        sakura
        tmux
        tree
        tup
        wget
        # vscode
        xen
        xorg.xcursorthemes
        zig
        zsh
      ];
    };
  };
}
