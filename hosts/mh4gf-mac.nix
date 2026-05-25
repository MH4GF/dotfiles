# Host entry for the personal Apple Silicon macOS machine.
# Sets the user-specific paths and imports the shared home.nix configuration.
{ ... }:

{
  imports = [ ../home.nix ];

  home.username = "mh4gf";
  home.homeDirectory = "/Users/mh4gf";

  # Schema version of HM state on this host. Pinned once; only bump after
  # reading the Home Manager release notes for the target version.
  home.stateVersion = "25.05";
}
