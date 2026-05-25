# Shared Home Manager base configuration imported by every host entry.
# Add cross-host modules to `imports`; host-specific values live in hosts/*.nix.
{ ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/shell.nix
    ./modules/git.nix
    ./modules/tmux.nix
    ./modules/neovim.nix
    ./modules/dev.nix
    ./modules/darwin.nix
    ./modules/secrets.nix
    ./modules/agent-skills.nix
  ];
}
