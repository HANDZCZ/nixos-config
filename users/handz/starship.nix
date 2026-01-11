{ lib, ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character.disabled = true;
      line_break.disabled = true;
      format = lib.concatStrings [
        "[┌─«](bold green) "
	"$all"
        "\n[└─»](bold green) "
      ];
    };
  };
}
