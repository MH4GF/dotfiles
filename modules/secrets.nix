# Local-only secrets (signing keys, API tokens) referenced from configs but
# never checked into git. The real files live in ~/.config/secrets/ and are
# linked into $HOME via mkOutOfStoreSymlink so edits don't require rebuilding
# Home Manager. setup-nix.sh creates empty stubs the first time so the
# symlinks never dangle.
#
# Expected files:
#   ~/.config/secrets/gitconfig.local  → included by programs.git.includes
#   ~/.config/secrets/zsh_secrets       → sourced from zshrc-extras.sh
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
