# macOS-only configuration: karabiner, iterm2, the SSH config that references
# 1Password's darwin agent socket, and a few mac-specific CLI tools.
# Wrapped in mkIf isDarwin so the module is a no-op on Linux hosts.
{ config, lib, pkgs, dotfilesPath, ... }:

{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.file = {
      # Karabiner-Elements writes karabiner.json back to disk when the user
      # changes mappings via the UI; mkOutOfStoreSymlink keeps those writes
      # in the dotfiles checkout (the Nix store is read-only).
      ".config/karabiner/karabiner.json".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/karabiner/karabiner.json";

      # iTerm2 rewrites its plist any time a preference changes — same reason
      # as karabiner.json for needing an out-of-store symlink.
      ".config/iterm2/com.googlecode.iterm2.plist".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/iterm2/com.googlecode.iterm2.plist";

      # SSH config points at the 1Password agent socket under Group Containers,
      # which only exists on macOS. Safe to plain-source: rarely edited.
      ".ssh/config".source = ../.ssh/config;

      # gpg-agent needs an explicit absolute path for pinentry on macOS.
      # If you have other gpg-agent customizations (default-cache-ttl etc.)
      # add them to this text block. After switching, run
      # `gpgconf --kill gpg-agent` once so the new path is picked up.
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
