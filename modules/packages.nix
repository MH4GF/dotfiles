{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    gnupg
    tig
    neovim
    ripgrep
    fd
    tree
    jq
    ghq
    peco
    gitleaks
    actionlint
    duckdb
    flock
    uv
    ffmpeg
    imagemagick
    awscli2
  ];
}
