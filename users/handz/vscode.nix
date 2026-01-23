{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    mutableExtensionsDir = false;
    profiles.default = {
      extensions = with pkgs.vscode-marketplace; [
        zhuangtongfa.material-theme
        emmanuelbeziat.vscode-great-icons
        vscodevim.vim
        # Rust
        rust-lang.rust-analyzer
        tamasfe.even-better-toml
        fill-labs.dependi
      ];
      userSettings = {
        workbench = {
          colorTheme = "One Dark Pro Darker";
          iconTheme = "vscode-great-icons";
        };
        editor = {
          fontFamily = "JetBrainsMono Nerd Font";
          fontLigatures = true;
          fontSize = 16;
          stickyScroll.enabled = false;
          maxTokenizationLineLength = 50000;
          largeFileOptimizations = false;
        };
        files = {
          autoSave = "afterDelay";
          eol = "\n";
        };
        git.openRepositoryInParentFolders = "never";
        vim = {
          smartRelativeLine = true;
        };
      };
      keybindings = [];
    };
  };
}
