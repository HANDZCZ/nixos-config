{ pkgs, lib, config, ... }:

let
  cfg = config.programs.noctalia-shell;

  wallpaperScript = pkgs.writeShellApplication rec {
    name = "noctalia-change-wallpaper";
    runtimeInputs = with pkgs; [
      coreutils-full
      findutils
      fd
    ];

    text = ''
      if [ "''${1:-}" == "--help" ] || [ "''${1:-}" == "-h" ]; then
        echo "A program to change noctalia wallpaper."
        echo ""
        echo "Usage: ${name} [--daily] [path]"
        echo ""
        echo "Arguments:"
        echo "  [path]    Path to wallpaper or directory (optional)."
        echo "            Default is '~/Pictures/Wallpapers/'."
        echo ""
        echo "Options:"
        echo "  -d, --daily    Change wallpaper only once a day."
        echo "  -h, --help     Show this help text."
        exit 1
      fi

      DAILY=false
      if [ "''${1:-}" == "--daily" ] || [ "''${1:-}" == "-d" ]; then
        DAILY=true
        shift
      fi

      LAST_CHANGED_FILE="$HOME/.cache/noctalia/daily_wallpaper_last_change"
      mkdir -p "''${LAST_CHANGED_FILE%/*}"
      USED_WALLPAPERS_FILE="$HOME/.cache/noctalia/daily_wallpaper_used_wallpapers"
      touch "$USED_WALLPAPERS_FILE"
      TODAY=$(date +%Y-%m-%d)
      CURRENT_WALLPAPER="$(noctalia-shell ipc call wallpaper get "")"
      WALLPAPERS_DIRECTORY="$HOME/Pictures/Wallpapers/"

      if [ -n "''${1:-}" ]; then
        abs_path="$(realpath "$1")"
        if [ -f "$abs_path" ]; then
          NEXT_WALLPAPER="$abs_path"
        else
          WALLPAPERS_DIRECTORY="$abs_path"
        fi
      fi

      if [ "$DAILY" == "false" ] || [ ! -f "$LAST_CHANGED_FILE" ] || [ "$(cat "$LAST_CHANGED_FILE")" != "$TODAY" ]; then
        if [ -z "''${NEXT_WALLPAPER:-}" ]; then
          all_wallpapers_in_dir="$(fd -t f . "$WALLPAPERS_DIRECTORY" | sort)"
          # pick random wallpaper that was not yet used
          NEXT_WALLPAPER="$(comm -23 - <(sort "$USED_WALLPAPERS_FILE") <<< "$all_wallpapers_in_dir" | sort -R | tail -1)"
          # if no wallpaper was found then from used wallpapers:
          #   remove all wallpaper paths that were found in the directory
          #   remove all invalid file paths (files that don't exist anymore)
          if [ -z "$NEXT_WALLPAPER" ]; then
            comm -13 - <(sort "$USED_WALLPAPERS_FILE") <<< "$all_wallpapers_in_dir" | xargs -d "\n" ls -1df 2>/dev/null | tee "$USED_WALLPAPERS_FILE" > /dev/null
            # try to pick wallpaper again
            NEXT_WALLPAPER="$(comm -23 - <(sort "$USED_WALLPAPERS_FILE") <<< "$all_wallpapers_in_dir" | sort -R | tail -1)"
          fi
        fi
        if [ -z "$NEXT_WALLPAPER" ]; then
          echo "No wallpaper was found in directory!"
          exit 1
        fi
        echo "Changing noctalia wallpaper for user '$USER' from '$CURRENT_WALLPAPER' to '$NEXT_WALLPAPER'."
        noctalia-shell ipc call wallpaper set "$NEXT_WALLPAPER" "all"
        echo "$TODAY" > "$LAST_CHANGED_FILE"
        echo "$NEXT_WALLPAPER" >> "$USED_WALLPAPERS_FILE"
      else
        echo "Noctalia wallpaper for user '$USER' was already changed to '$CURRENT_WALLPAPER' today."
        echo "If you want to change it anyway omit the '--daily' option."
      fi
    '';
  };
in {
  options.programs.noctalia-shell = {
    dailyWallpaper = lib.mkEnableOption "daily wallpaper change";
    wallpaperScript = lib.mkEnableOption "" // {
      default = true;
      description = "Whether to add script for changing wallpaper to `home.packages`.";
    };
  };

  config = {
    home.packages = lib.optional cfg.wallpaperScript wallpaperScript;
    programs.noctalia-shell = {
      extraPackages = lib.optional cfg.dailyWallpaper wallpaperScript;
      overlays = lib.optional cfg.dailyWallpaper (_: prev: prev.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          ../../../patches/noctalia/Add-wallpaper-change-on-startup.patch
        ];
      }));
    };
  };
}
