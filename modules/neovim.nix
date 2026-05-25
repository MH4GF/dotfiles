# Editors: Neovim (Nix-installed) plus vim and IdeaVim configs.
# init.lua is symlinked back into the dotfiles checkout via mkOutOfStoreSymlink
# so edits to the file in this repo take effect without re-running
# `home-manager switch`. lazy.nvim continues to manage plugins at runtime.
{ config, dotfilesPath, ... }:

{
  programs.neovim.enable = true;

  home.file = {
    ".config/nvim/init.lua".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/.config/nvim/init.lua";

    ".vimrc".text = ''
      inoremap <silent> jj <ESC>
      set clipboard+=unnamed
      set number
      syntax on
    '';

    ".ideavimrc".text = ''
      inoremap <silent> jj <ESC>
    '';
  };
}
