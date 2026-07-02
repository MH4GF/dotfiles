{ ... }:

{
  imports = [ ../home.nix ];

  home.username = "hirotaka.miyagi.001";
  home.homeDirectory = "/Users/hirotaka.miyagi.001";

  _module.args.dotfilesPath = "/Users/hirotaka.miyagi.001/ghq/github.com/MH4GF/dotfiles";

  home.stateVersion = "25.05";
}
