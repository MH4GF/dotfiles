# Developer tooling that needs shell-init hooks (mise / direnv).
# programs.{mise,direnv} auto-inject their eval hooks into zsh, so the manual
# `eval "$(... activate / hook zsh)"` lines are dropped from zshrc-extras.sh.
{ ... }:

{
  programs.mise = {
    enable = true;
    # .config/mise/config.toml is managed outside Nix (current setup.sh
    # symlinks it from the dotfiles tree); HM only injects shell integration.
  };

  programs.direnv = {
    enable = true;
    # nix-direnv adds `use flake` support; introducing that is a separate
    # task per the migration plan, so keep vanilla direnv behavior for now.
    nix-direnv.enable = false;
  };
}
