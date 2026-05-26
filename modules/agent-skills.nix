{ config, dotfilesPath, ... }:

{
  home.file.".local/bin/cc-human-review".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/bin/cc-human-review";
}
