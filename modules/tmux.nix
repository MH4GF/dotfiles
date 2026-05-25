# Tmux configuration. The .tmux.conf content is only three lines so we inline
# it via home.file rather than going through programs.tmux's structured options.
# tmux itself is installed via brew (not in Brewfile yet); add pkgs.tmux to
# packages.nix later if a Nix-managed binary is preferred.
{ ... }:

{
  home.file.".tmux.conf".text = ''
    set -g mouse on
    set -g default-shell /bin/zsh
    set-hook -g after-split-window "select-layout even-horizontal"
  '';
}
