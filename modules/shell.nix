# Shell-level configuration: prompt, zsh, completions, history, env vars, PATH.
# Long shell snippets live in ./zshrc-extras.sh and are inlined via readFile.
{ lib, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      memory_usage = {
        disabled = false;
        threshold = -1;
        style = "bold dimmed green";
      };
      gcloud.disabled = true;
      nodejs.disabled = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    history = {
      path = "$HOME/.zsh_history";
      size = 100000;
      save = 100000;
      ignoreAllDups = true;
      ignoreDups = true;
    };

    shellAliases = {
      ghql = "cd $(ghq root)/$(ghq list | peco)";
      gp = "git push -u origin $(git branch --show-current)";
      gpf = "git push -u --force-with-lease origin $(git branch --show-current)";
      dc = "docker compose";
      ll = "ls -laG";
      wakatime = "docker run --rm -it mh4gf/wakatime-cli";
      textlint = "$HOME/.ghq/github.com/MH4GF/my-textlint/node_modules/.bin/textlint -c $HOME/.ghq/github.com/MH4GF/my-textlint/.textlintrc";
      devc = "devcontainer open";
      nf = ''nvim +"lua vim.defer_fn(function() require('telescope.builtin').find_files() end, 100)"'';
      ng = ''nvim +"lua vim.defer_fn(function() require('telescope.builtin').live_grep() end, 100)"'';
    };

    completionInit = ''
      autoload colors
      autoload -Uz compinit
      compinit
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*' list-colors '''
      setopt list_packed
      setopt correct
    '';

    initContent = builtins.readFile ./zshrc-extras.sh;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    AWS_SDK_LOAD_CONFIG = "1";
    CPLUS_INCLUDE_PATH = "$CPLUS_INCLUDE_PATH:$HOME/cpp/include/";
    BUN_INSTALL = "$HOME/.bun";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.bun/bin"
    "$HOME/.deno/bin"
    "$HOME/.duckdb/cli/latest"
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    "/Applications/WezTerm.app/Contents/MacOS"
  ];

  home.packages = with pkgs; [
    # Generic completions for tools that don't ship their own.
    zsh-completions
  ];
}
