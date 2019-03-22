# NOTE(akavel): this file can be either a set, or a func (both are allowed).
{
  # TODO(akavel): set $EDITOR to vim
  packageOverrides = defaultPkgs: with defaultPkgs; {
    # NOTE(akavel): `pkgs` below contains "final" packages "from the future",
    # after all overrides. And `defaultPkgs` contains packages in "pristine"
    # state (before any of the following overrides were applied).

    # "Declarative user profile/config". Install:
    # `nix-env -iA nixos.home`
    home = with pkgs; buildEnv {

      name = "home";

      paths = [
        acpi
        alacritty
        emacs
        ffmpeg
        fira-code
        firefox
        fish
        git
        htop
        ktorrent
        mpv
        neovim
        pkg-config
        psmisc
        pstree
        redshift
        tmux
        tree
      ];
    };
  };
}
