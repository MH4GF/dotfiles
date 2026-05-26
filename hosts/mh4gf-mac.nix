{ ... }:

{
  imports = [ ../home.nix ];

  home.username = "mh4gf";
  home.homeDirectory = "/Users/mh4gf";

  _module.args.dotfilesPath = "/Users/mh4gf/ghq/github.com/MH4GF/dotfiles";

  home.stateVersion = "25.05";
}
