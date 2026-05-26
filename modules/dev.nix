{ config, dotfilesPath, ... }:

{
  programs.mise = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = false;
  };

  home.file.".config/mise/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/mise/config.toml";
}
