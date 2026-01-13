{ ... }:

{
  services.polkit-gnome.enable = true;

  # fixes crashing on start when using niri
  # error: polkit-gnome-authentication-agent-1[312208]: cannot open display:
  systemd.user.services.polkit-gnome = {
    Service = {
      Restart = "on-failure";
      RestartSec = 1;
    };
    Unit = {
      StartLimitIntervalSec = 30;
      StartLimitBurst = 10;
    };
  };
}
