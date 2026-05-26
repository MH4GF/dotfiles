# CLI tools Nix installs into the user profile.
# Tools requiring brew due to absolute-path references in other configs are
# intentionally kept on Homebrew (see plan: gh, gnupg, pinentry-mac, mas).
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Version control & signing
    git
    gnupg
    tig

    # Editor (config managed by modules/neovim.nix)
    neovim

    # Search & format
    ripgrep
    fd
    tree
    jq
    ghq
    peco

    # Development helpers
    gitleaks
    actionlint
    duckdb
    flock
    uv

    # Media
    ffmpeg
    imagemagick

    # AWS
    awscli2
  ];
}
