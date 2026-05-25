# Agent-related scripts and prompt directories that need to live under $HOME.
# Currently:
#   - bin/cc-human-review → ~/.local/bin/cc-human-review (tmux split helper)
#   - .config/tq/prompts/ → ~/.config/tq/prompts (tq prompt templates)
# Both use mkOutOfStoreSymlink so edits in the dotfiles tree take effect
# immediately. This is also the natural home for a future Claude Code Web
# bootstrap module (kumewata-style agent-skills).
{ config, dotfilesPath, ... }:

{
  home.file = {
    ".local/bin/cc-human-review".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/bin/cc-human-review";

    ".config/tq/prompts".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/tq/prompts";
  };
}
