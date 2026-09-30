{ config, lib, pkgs, ... }:

let
  cfg = config.services.dell-fancontrol;
in {
  options.services.dell-fancontrol = {
    enable = lib.mkEnableOption "fan control for dell server";
    package = lib.mkPackageOption pkgs "poweredge-shutup" {};
    timeout = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 5;
      description = "Time to wait until script/service gets restarted.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.dell-fancontrol = {
      description = "Dell server fancontrol";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package}";
        Restart = "always";
        RestartSec = cfg.timeout;
      };
    };
  };
}
