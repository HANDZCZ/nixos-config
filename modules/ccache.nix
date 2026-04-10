{ config, lib, pkgs, ... }:

let
  cfg = config.programs.ccache;
in {
  options.programs.ccache = {
    addToSandboxPaths = lib.mkEnableOption "" // {
      default = true;
      description = "Whether to add `cacheDir` to `nix.settings.extra-sandbox-paths`.";
    };
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = ''
        compression = true
        sloppiness = random_seed
        umask = 007
        max_size = 16G
        compiler_check = content
      '';
      description = ''
        Extra config that will be passed to ccache and written to `${cfg.cacheDir}/ccache.conf`.
        CAUTION: every change causes recompilation of all packages that use `ccacheStdenv`!
      '';
    };
  };

  config = let
    ccacheConfigFile = pkgs.writeText "ccache.conf" ''
      ${cfg.extraConfig}
      cache_dir = ${cfg.cacheDir}
    '';
  in lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ ccache ];
    nix.settings.extra-sandbox-paths = lib.optionals cfg.addToSandboxPaths [ "${cfg.cacheDir}" ];
    systemd.tmpfiles.rules = lib.mkIf (cfg.extraConfig != "") [ "L+ ${cfg.cacheDir}/ccache.conf - - - - ${ccacheConfigFile}" ];

    nixpkgs.overlays = [
      (final: prev: {
        ccacheWrapper = prev.ccacheWrapper.override {
          extraConfig = /* bash */ ''
            CCACHE_DIR="${cfg.cacheDir}"
            export CCACHE_CONFIGPATH="''${CCACHE_CONFIGPATH:-${ccacheConfigFile}}"
            if [ ! -d "$CCACHE_DIR" ]; then
              echo "====="
              echo "Directory '$CCACHE_DIR' does not exist"
              echo "Please create it with:"
              echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
              echo "  sudo chown ${cfg.owner}:${cfg.group} '$CCACHE_DIR'"
              echo "====="
              exit 1
            fi
            if [ ! -w "$CCACHE_DIR" ]; then
              echo "====="
              echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
              echo "Please verify its access permissions"
              echo "====="
              exit 1
            fi
          '';
        };
      })
    ];
  };
}
