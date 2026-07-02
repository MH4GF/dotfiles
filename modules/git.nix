{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "MH4GF";
        email = "h.miyagi.cnw@gmail.com";
      };

      alias = {
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
      gpg.program = "gpg";
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

  home.file.".githooks/pre-commit" = {
    source = ../.githooks/pre-commit;
    executable = true;
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = false;
    settings = {
      git_protocol = "ssh";
      editor = "";
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

  home.file.".tigrc".text = ''
    set wrap-lines = yes
  '';
}
