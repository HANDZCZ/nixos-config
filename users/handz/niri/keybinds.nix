{ pkgs, lib, ... }:

# TODO: change keybinds for terminal, launcher, etc. based on some variable
let
  workspace-keys = {
    keys = ["Plus" "ecaron" "scaron" "ccaron" "rcaron" "zcaron" "yacute" "aacute" "iacute"];
    move-col-mod = "Shift";
  };
  move-workspace-keys = {
    up = [ "Page_Up" "KP_Prior" ];
    down = [ "Page_Down" "KP_Next" ];
    move-ws-mod = "Shift";
    move-col-mod = "Ctrl";
  };
in {
  wayland.windowManager.niri.settings.binds = {
    "Mod+Shift+O".show-hotkey-overlay = {};
    # fallback terminal so some terminal is always available
    "Mod+T" = {
      _props.hotkey-overlay-title = "Open a Terminal: XTerm";
      spawn = "${lib.getExe pkgs.xterm}";
    };
    "Ctrl+Alt+T" = {
      _props.hotkey-overlay-title = "Open a Terminal: Alacritty";
      spawn = "alacritty";
    };
    "Mod+Return" = {
      _props.hotkey-overlay-title = "Run app selector";
      spawn-sh = "noctalia-shell ipc call launcher toggle";
    };
    "Mod+V" = {
      _props.hotkey-overlay-title = "Clipboard history";
      spawn-sh = "noctalia-shell ipc call launcher clipboard";
    };
    "Mod+L" = {
      _props.hotkey-overlay-title = "Lock the screen";
      spawn-sh = "noctalia-shell ipc call lockScreen lock";
    };

    XF86PowerOff = {
      power-off-monitors = {};
    };

    XF86AudioRaiseVolume = {
      _props.allow-when-locked = true;
      spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+ -l 1.0";
    };
    XF86AudioLowerVolume = {
      _props.allow-when-locked = true;
      spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01-";
    };
    XF86AudioMute = {
      _props.allow-when-locked = true;
      spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    };
    XF86AudioMicMute = {
      _props.allow-when-locked = true;
      spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    };

    XF86AudioPlay = {
      _props.allow-when-locked = true;
      spawn-sh = "playerctl play-pause";
    };
    XF86AudioStop = {
      _props.allow-when-locked = true;
      spawn-sh = "playerctl stop";
    };
    XF86AudioPrev = {
      _props.allow-when-locked = true;
      spawn-sh = "playerctl previous";
    };
    XF86AudioNext = {
      _props.allow-when-locked = true;
      spawn-sh = "playerctl next";
    };

    /*XF86MonBrightnessUp = {
      allow-when-locked = true;
      spawn-sh = "brightnessctl --class=backlight set +10%";
    };
    XF86MonBrightnessDown = {
      allow-when-locked = true;
      spawn-sh = "brightnessctl --class=backlight set 10%-";
    };*/

    "Mod+O" = {
      _props = {
        hotkey-overlay-title = "Toggle overview";
        repeat = false;
      };
      toggle-overview = {};
    };
    "Mod+Q" = {
      _props = {
        hotkey-overlay-title = "Close window";
        repeat = false;
      };
      close-window = {};
    };

    "Mod+Home" = {
      _props.hotkey-overlay-title = "Focus first column";
      focus-column-first = {};
    };
    "Mod+End" = {
      _props.hotkey-overlay-title = "Focus last column";
      focus-column-last = {};
    };

    "Mod+Left" = {
      _props.hotkey-overlay-title = "Focus column left";
      focus-column-left = {};
    };
    "Mod+Right" = {
      _props.hotkey-overlay-title = "Focus column right";
      focus-column-right = {};
    };
    "Mod+Up" = {
      _props.hotkey-overlay-title = "Focus window up";
      focus-window-up = {};
    };
    "Mod+Down" = {
      _props.hotkey-overlay-title = "Focus window down";
      focus-window-down = {};
    };

    "Mod+Ctrl+Left" = {
      _props.hotkey-overlay-title = "Move column left";
      move-column-left = {};
    };
    "Mod+Ctrl+Right" = {
      _props.hotkey-overlay-title = "Move column right";
      move-column-right = {};
    };
    "Mod+Ctrl+Up" = {
      _props.hotkey-overlay-title = "Move window up";
      move-window-up = {};
    };
    "Mod+Ctrl+Down" = {
      _props.hotkey-overlay-title = "Move window down";
      move-window-down = {};
    };

    "Mod+R" = {
      _props.hotkey-overlay-title = "Switch preset column width";
      switch-preset-column-width = {};
    };
    "Mod+F" = {
      _props.hotkey-overlay-title = "Maximize column";
      maximize-column = {};
    };
    "Mod+Shift+R" = {
      _props.hotkey-overlay-title = "Switch preset window height";
      switch-preset-window-height = {};
    };
    "Mod+Ctrl+R" = {
      _props.hotkey-overlay-title = "Reset window height";
      reset-window-height = {};
    };
    "Mod+C" = {
      _props.hotkey-overlay-title = "Center column";
      center-column = {};
    };

    "Mod+Equal" = {
      _props.hotkey-overlay-title = "Set column width +10%";
      set-column-width = "+10%";
    };
    "Mod+dead_acute" = {
      _props.hotkey-overlay-title = "Set column width -10%";
      set-column-width = "-10%";
    };
    "Mod+Shift+Equal" = {
      _props.hotkey-overlay-title = "Set window height +10%";
      set-window-height = "+10%";
    };
    "Mod+Shift+dead_acute" = {
      _props.hotkey-overlay-title = "Set window height -10%";
      set-window-height = "-10%";
    };

    "Mod+M" = {
      _props.hotkey-overlay-title = "Toggle window floating";
      toggle-window-floating = {};
    };
    "Mod+Shift+M" = {
      _props.hotkey-overlay-title = "Switch focus between floating and tiling";
      switch-focus-between-floating-and-tiling = {};
    };

    "Print" = {
      _props.hotkey-overlay-title = "Screenshot";
      screenshot = {};
    };
    "Ctrl+Print" = {
      _props.hotkey-overlay-title = "Screenshot screen";
      screenshot-screen = {};
    };
    "Alt+Print" = {
      _props.hotkey-overlay-title = "Screenshot window";
      screenshot-window = {};
    };

    "Mod+Escape" = {
      _props = {
        allow-inhibiting = false;
        hotkey-overlay-title = "Toggle keyboard shortcuts inhibit";
      };
      toggle-keyboard-shortcuts-inhibit = {};
    };

    "Mod+Shift+E" = {
      _props.hotkey-overlay-title = "Quit niri";
      quit = {};
    };
    "Ctrl+Alt+Delete" = {
      _props.hotkey-overlay-title = "Open session menu";
      spawn-sh = "noctalia-shell ipc call sessionMenu toggle";
    };

    "Mod+P" = {
      _props.hotkey-overlay-title = "Set dynamic cast window";
      set-dynamic-cast-window = {};
    };
    "Mod+Shift+P" = {
      _props.hotkey-overlay-title = "Set dynamic cast monitor";
      set-dynamic-cast-monitor = {};
    };
    "Mod+Ctrl+P" = {
      _props.hotkey-overlay-title = "Clear dynamic cast target";
      clear-dynamic-cast-target = {};
    };

    "Mod+Shift+F" = {
      _props.hotkey-overlay-title = "Toggle windowed fullscreen";
      toggle-windowed-fullscreen = {};
    };
    "Mod+Ctrl+Shift+F" = {
      _props.hotkey-overlay-title = "Fullscreen window";
      fullscreen-window = {};
    };
    "Mod+Ctrl+M" = {
      _props.hotkey-overlay-title = "Maximize window to edges";
      maximize-window-to-edges = {};
    };
  }
    // (workspace-keys.keys
      |> lib.imap1 (ws: key: {
        "Mod+${key}" = {
          #_props.hotkey-overlay-title = "Focus workspace ${toString ws}";
          focus-workspace = ws;
        };
        "Mod+${workspace-keys.move-col-mod}+${key}" = {
          #_props.hotkey-overlay-title = "Move column to workspace ${toString ws}";
          move-column-to-workspace = ws;
        };
      })
      |> lib.mergeAttrsList)
    // ([ "up" "down" ]
      |> lib.map (dir: move-workspace-keys.${dir} |> lib.map (key: {
        "Mod+${key}" = {
          _props.hotkey-overlay-title = "Focus workspace ${dir}";
          "focus-workspace-${dir}" = {};
        };
        "Mod+${move-workspace-keys.move-ws-mod}+${key}" = {
          _props.hotkey-overlay-title = "Move workspace ${dir}";
          "move-workspace-${dir}" = {};
        };
        "Mod+${move-workspace-keys.move-col-mod}+${key}" = {
          _props.hotkey-overlay-title = "Move column to workspace ${dir}";
          "move-column-to-workspace-${dir}" = {};
        };
      }))
      |> lib.flatten
      |> lib.mergeAttrsList);
}
