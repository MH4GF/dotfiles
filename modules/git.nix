# Git configuration: user identity, aliases, core options, credential helpers,
# global ignore, hooks directory, plus gh and tig.
{ ... }:

{
  programs.git = {
    enable = true;
    userName = "MH4GF";
    userEmail = "h.miyagi.cnw@gmail.com";

    aliases = {
      cma = "commit --amend";
      co = ''!f() { [ $# -eq 0 ] && git checkout $(git branch --sort=-authordate | perl -a -nle '$F[0] ne "*" and print $F[0]' | peco) || git checkout $@; }; f'';
      com = ''!f() { remote_head=$(git symbolic-ref --quiet refs/remotes/origin/HEAD); remote_head=''${remote_head#refs/remotes/origin/}; git checkout ''${remote_head:-$(git rev-parse --symbolic --verify --quiet main || git rev-parse --symbolic --verify --quiet master)}; git pull; }; f'';
      comw = ''!f() { \
        remote_head=$(git symbolic-ref --quiet refs/remotes/origin/HEAD); \
        remote_head=''${remote_head#refs/remotes/origin/}; \
        main_branch=''${remote_head:-$(git rev-parse --symbolic --verify --quiet main || git rev-parse --symbolic --verify --quiet master)}; \
        git checkout $main_branch; \
        git pull; \
        merged_branches=$(git branch --merged | grep -v "*" | grep -v "origin/" | sed 's/^[+ ]*//' | tr -d ' '); \
        git worktree list | tail -n +2 | while read path hash branch; do \
          branch_name=$(echo $branch | tr -d '[]'); \
          if echo "$merged_branches" | grep -q "^$branch_name$"; then \
            git worktree remove "$path" 2>/dev/null || true; \
          fi; \
        done; \
        git branch --merged | grep -v "*" | grep -v "origin/" | sed 's/^[+ ]*//' | xargs -I % git branch -d % 2>/dev/null || true; \
      }; f'';
      cp = "cherry-pick";
      wa = ''!f() { repo_name=$(basename $(git rev-parse --show-toplevel)); branch_dir=$(echo $1 | tr '/' '-'); git worktree add ../''${repo_name}-worktree/''${branch_dir} -b $1; }; f'';
      war = ''!f() { repo_name=$(basename $(git rev-parse --show-toplevel)); branch_dir=$(echo $1 | tr '/' '-'); git worktree add --track -b $1 ../''${repo_name}-worktree/''${branch_dir} origin/$1; }; f'';
      wt = "worktree";
    };

    extraConfig = {
      ghq.root = "~/ghq";
      core = {
        editor = "nvim";
        symlinks = true;
        commentChar = ">";
        quotePath = false;
        hooksPath = "~/.githooks";
      };
      fetch.prune = true;
      pull.rebase = true;
      init.defaultBranch = "main";
      commit.gpgsign = true;
      "github-nippou".user = "MH4GF";
      rerere.enabled = true;
      gpg.program = "/opt/homebrew/bin/gpg";
      credential = {
        "https://github.com".helper = [
          ""
          "!gh auth git-credential"
        ];
        "https://gist.github.com".helper = [
          ""
          "!gh auth git-credential"
        ];
      };
    };

    includes = [
      { path = "~/.gitconfig.local"; }
    ];

    # Global gitignore (~/.config/git/ignore)
    ignores = [
      ".idea/"
      ".DS_Store"
      ".vscode/settings.json"
      ".claude/settings.local.json"
      ".gitignore_local"
      ".issync/"
      ".envrc"
      "**/.claude/settings.local.json"
      ".mcp.json"
      "__pycache__/"
      "lefthook-local.yml"
      "compose.override.yml"
      "compose.override.yaml"
      ".claude/plans/"
      ".claude/qa/"
      ".claude/tmp/"
      ".claude/worktrees/"
    ];
  };

  # Hook scripts referenced by core.hooksPath. Only the tracked pre-commit
  # script is managed here; add new hooks alongside as they get committed.
  home.file.".githooks/pre-commit" = {
    source = ../.githooks/pre-commit;
    executable = true;
  };

  programs.gh = {
    enable = true;
    # Credential helper is configured manually in programs.git.extraConfig
    # so it points at the brew gh binary (matches the existing setup).
    gitCredentialHelper.enable = false;
    settings = {
      git_protocol = "ssh";
      editor = null;
      prompt = "enabled";
      version = "1";
      aliases = {
        co = "pr checkout";
        pv = "pr view --web";
        b = "browse -c";
        prv = "pr view --web";
        prc = "pr create --fill --draft";
      };
    };
  };

  programs.tig = {
    enable = true;
    extraConfig = [
      "set wrap-lines = yes"
    ];
  };
}
