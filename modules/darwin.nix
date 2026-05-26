{ config, lib, pkgs, dotfilesPath, ... }:

{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.file = {
      ".config/karabiner/karabiner.json".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/karabiner/karabiner.json";

      ".config/iterm2/com.googlecode.iterm2.plist".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/iterm2/com.googlecode.iterm2.plist";

      ".ssh/config".source = ../.ssh/config;

      ".gnupg/gpg-agent.conf".text = ''
        pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
      '';
    };

    home.packages = with pkgs; [
      mas
      terminal-notifier
      pinentry_mac
    ];
  };
}
