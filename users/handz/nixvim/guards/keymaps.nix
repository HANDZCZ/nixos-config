{ config, lib, inputs, ... }:

let
  keymaps = config.programs.nixvim.keymaps;
  toLuaObject = inputs.nixvim.lib.nixvim.toLuaObject;
in {
  warnings = keymaps
    |> lib.map (keybind: { inherit (keybind) key mode; })
    |> lib.unique
    |> lib.map (keybind:
      let
        all-defs = keymaps
          |> lib.filter (k:
              keybind.key == k.key
              && lib.count (lib.intersectLists keybind.mode k.mode) != 0
            )
          |> lib.unique;
      in keybind // { inherit all-defs; })
    |> lib.filter (keybind: lib.length keybind.all-defs != 1)
    |> lib.map (keybind: ''
      Nixvim: keybind '${keybind.key}' with modes '${toString keybind.mode}' defined multiple times.
      Keybind defs: ${keybind.all-defs |> lib.map (attrs: lib.removeAttrs attrs [ "lua" ]) |> toLuaObject}
    '');
}

