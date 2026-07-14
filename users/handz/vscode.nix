{ pkgs, lib, user-info, ... }:

{
  home-manager.users.${user-info.name}.programs.vscodium = {
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
        # Nix
        jnoortheen.nix-ide
        # Presentations
        marp-team.marp-vscode
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
        markdown.marp = {
          enableHtml = true;
          pdf.noteAnnotations = true;
          # TODO: set chromium based browser to the one user uses or just set it to some chromium
          chromePath = lib.getExe pkgs.brave;
        };
      };
      keybindings = [
        {
          key = "alt+k";
          command = "editor.action.moveLinesUpAction";
          when = "editorTextFocus && !editorReadonly";
        }
        {
          key = "alt+j";
          command = "editor.action.moveLinesDownAction";
          when = "editorTextFocus && !editorReadonly";
        }
        {
          key = "ctrl+numpad_multiply";
          command = "rust-analyzer.expandMacro";
        }
        {
          key = "ctrl+alt+l";
          command = "editor.action.formatDocument";
          when = "editorHasDocumentFormattingProvider && editorTextFocus && !editorReadonly && !inCompositeEditor";
        }
        {
          key = "alt+enter";
          command = "editor.action.quickFix";
          when = "editorHasCodeActionsProvider && textInputFocus && !editorReadonly";
        }
        # remove defaults
        {
          key = "ctrl+shift+i";
          command = "-editor.action.formatDocument";
          when = "editorHasDocumentFormattingProvider && editorTextFocus && !editorReadonly && !inCompositeEditor";
        }
        {
          key = "ctrl+[Period]";
          command = "-editor.action.quickFix";
          when = "editorHasCodeActionsProvider && textInputFocus && !editorReadonly";
        }
        {
          key = "ctrl+shift+v";
          command = "-markdown.showPreview";
          when = "!notebookEditorFocused && editorLangId =~ /^(markdown|prompt|instructions|chatmode)$/";
        }
      ];
    };
  };
}
