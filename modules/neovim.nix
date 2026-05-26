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
