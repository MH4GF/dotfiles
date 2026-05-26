{ config, ... }:

let
  secretsRoot = "${config.home.homeDirectory}/.config/secrets";
in
{
  home.file = {
    ".gitconfig.local".source =
      config.lib.file.mkOutOfStoreSymlink "${secretsRoot}/gitconfig.local";
    ".zsh_secrets".source =
      config.lib.file.mkOutOfStoreSymlink "${secretsRoot}/zsh_secrets";
  };
}
