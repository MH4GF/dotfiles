{ config, pkgs, dotfilesPath, ... }:

{
  programs.mise = {
    enable = true;
  };

  # mise の shim が効かない cron と `#!/usr/bin/env node` の npm CLI (works の npm-globals) 向けに、
  # 固定パス (~/.nix-profile/bin) の node を置く。対話シェルでは mise の node が優先される。
  home.packages = [ pkgs.nodejs_24 ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = false;
  };

  home.file.".config/mise/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/mise/config.toml";
}
