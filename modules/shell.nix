# Shell-level configuration: prompt, zsh, completions, history, init hooks.
# Later phases will add programs.zsh here; this phase only covers starship.
{ ... }:

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
}
