{ osConfig, config, ... }:

{
  programs.nixvim = {
    plugins = {
      lsp = {
        enable = true;
        servers = {
          nil_ls = {
            enable = true;
            settings = {
              nix = {
                maxMemoryMB = 12 * 1024;
                flake = {
                  autoEvalInputs = true;
                  nixpkgsInputName = "nixpkgs";
                };
              };
            };
          };
          nixd = {
            enable = true;
            settings =
              let
                flake = /* nix */ ''(builtins.getFlake "${config.xdg.configHome}/nixos")'';
              in {
                nixpkgs.expr = /* nix */ "import ${flake}.inputs.nixpkgs {}";
                options = {
                  nixos.expr = /* nix */ "${flake}.nixosConfigurations.${osConfig.system.name}.options";
                  home-manager.expr = /* nix */ ''
                    let
                      flake = ${flake};
                      pkgs = import flake.inputs.nixpkgs {};
                      pkgs-unstable = import flake.inputs.nixpkgs-unstable {};
                    in (flake.inputs.home-manager.lib.homeManagerConfiguration {
                      inherit pkgs;
                      modules = [
                        ${config.xdg.configHome}/nixos/users/${config.home.username}/home.nix
                        {
                          home = {
                            username = "${config.home.username}";
                            homeDirectory = "${config.home.homeDirectory}";
                            stateVersion = "${config.home.stateVersion}";
                          };
                        }
                      ];
                      extraSpecialArgs = {
                        inherit pkgs-unstable;
                        inputs = flake.inputs;
                        osConfig = flake.nixosConfigurations.nixos-desktop.config;
                      };
                    }).options
                  '';
                };
              };
          };
        };
        luaConfig.post = ''
          vim.api.nvim_set_hl(0, "DiagnosticDeprecated", { strikethrough = false })
        '';
      };
    };
  };
}

