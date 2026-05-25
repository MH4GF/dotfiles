# Host entry for the personal Apple Silicon macOS machine.
# Sets the user-specific paths and imports the shared home.nix configuration.
{ ... }:

{
  imports = [ ../home.nix ];

  home.username = "mh4gf";
  home.homeDirectory = "/Users/mh4gf";

  # Absolute path to the dotfiles checkout on this host. Modules that want
  # edits to propagate without re-running `home-manager switch` (via
  # mkOutOfStoreSymlink) read this through _module.args.
  _module.args.dotfilesPath = "/Users/mh4gf/ghq/github.com/MH4GF/dotfiles";

  # Schema version of HM state on this host. Pinned once; only bump after
  # reading the Home Manager release notes for the target version.
  home.stateVersion = "25.05";
}
