# CLI tools Nix installs into the user profile.
# Tools requiring brew due to absolute-path references in other configs are
# intentionally kept on Homebrew (see plan: gh, gnupg, pinentry-mac, mas).
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Populated by later phases. Empty bootstrap for now.
  ];
}
