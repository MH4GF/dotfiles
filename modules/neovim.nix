# Editors: Neovim configs plus vim and IdeaVim. Neovim binary itself is
# installed via packages.nix; programs.neovim would otherwise create its own
# managed ~/.config/nvim/init.lua and conflict with the mkOutOfStoreSymlink
# below that points back into the dotfiles checkout.
{ config, dotfilesPath, ... }:

{
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
