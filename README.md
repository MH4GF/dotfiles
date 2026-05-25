# dotfiles

Personal macOS setup managed by Nix Flakes + Home Manager (standalone).

## Quick Start

### Full setup on a new Mac

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/MH4GF/dotfiles/master/setup_macos.sh)"
```

This script installs Xcode CLT, Homebrew, the Brewfile (mainly GUI casks and
gh/gpg/pinentry-mac), clones the dotfiles via ghq, then runs `setup-nix.sh`
to install Nix and apply the Home Manager configuration.

### Existing machine — apply Home Manager only

```bash
./setup-nix.sh                                  # first time (installs Nix + applies HM)
home-manager switch --flake .#mh4gf-mac         # ongoing
```

## Layout

| Path | Purpose |
| --- | --- |
| `flake.nix`, `flake.lock` | Flake entrypoint + pinned inputs (`nixpkgs` nixos-unstable, `home-manager` master) |
| `home.nix` | Shared Home Manager base; imports every `modules/*.nix` |
| `hosts/mh4gf-mac.nix` | Per-host entry (username, $HOME, dotfiles path, stateVersion) |
| `modules/packages.nix` | CLI tools installed via `home.packages` |
| `modules/shell.nix` | `programs.zsh` + `programs.starship` + history / aliases / env / PATH |
| `modules/zshrc-extras.sh` | Long zsh snippets inlined into `programs.zsh.initContent` |
| `modules/git.nix` | `programs.git` + `programs.gh` + `programs.tig`, githooks placement |
| `modules/tmux.nix` | Inline `.tmux.conf` content |
| `modules/neovim.nix` | `programs.neovim` + `init.lua` symlink + `.vimrc` / `.ideavimrc` |
| `modules/dev.nix` | `programs.mise`, `programs.direnv`, mise config symlink |
| `modules/darwin.nix` | macOS-only (karabiner, iterm2, ssh config, mas, terminal-notifier) |
| `modules/secrets.nix` | `~/.gitconfig.local` / `~/.zsh_secrets` → `~/.config/secrets/` |
| `modules/agent-skills.nix` | `bin/cc-human-review` + `.config/tq/prompts` symlinks |
| `Brewfile` | GUI casks + brew-pinned CLI (`git`, `gh`, `gpg`, `pinentry-mac`) |
| `setup_macos.sh` | Bootstrap: Xcode CLT, Homebrew, brew bundle, `defaults write`, `pmset` |
| `setup-nix.sh` | Bootstrap: Determinate Nix installer + first `home-manager switch` + secret stubs |

## Manual setup after the script

1. Sign in to 1Password (SSH keys are managed there)
2. Populate `~/.config/secrets/`:
   - `gitconfig.local` — `[user] signingkey = ...`
   - `zsh_secrets` — `export OPENAI_API_KEY=...` etc.
3. Generate / import GPG key and reference it in `~/.config/secrets/gitconfig.local`
4. Configure iTerm2: Preferences → General → Preferences → load from `~/.config/iterm2`
5. Restart the machine for all macOS preferences to take effect

## Customization

- Add a new tool: append to `home.packages` in `modules/packages.nix`
- Add a new zsh alias: extend `programs.zsh.shellAliases` in `modules/shell.nix`
- Add a host (e.g., a Linux machine): copy `hosts/mh4gf-mac.nix` to
  `hosts/<name>.nix`, adjust username / home / dotfilesPath, and register
  the new `homeConfigurations.<name>` entry in `flake.nix`.

## Rollback

Home Manager keeps every generation. To go back one step:

```bash
home-manager generations                       # list past generations
home-manager switch --switch-generation <N>    # roll back
```
