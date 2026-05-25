# Developer tooling that needs shell-init hooks (mise / direnv) plus the
# mise config file itself. programs.{mise,direnv} auto-inject their eval
# hooks into zsh, so the manual `eval "$(... activate / hook zsh)"` lines
# are dropped from zshrc-extras.sh.
{ config, dotfilesPath, ... }:

{
  programs.mise = {
    enable = true;
    # HM only injects shell integration; the actual config file is symlinked
    # from the dotfiles tree below so `mise use` etc. edit the tracked file.
  };

  programs.direnv = {
    enable = true;
    # nix-direnv adds `use flake` support; introducing that is a separate
    # task per the migration plan, so keep vanilla direnv behavior for now.
    nix-direnv.enable = false;
  };

  home.file.".config/mise/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/mise/config.toml";
}
