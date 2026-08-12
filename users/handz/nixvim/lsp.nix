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
                  home-manager.expr = /* nix */ "${flake}.nixosConfigurations.${osConfig.system.name}.options.home-manager.users.type.getSubOptions []";
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

