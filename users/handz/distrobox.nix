{ hm-config, user-info, ...}:

let
  xdg = hm-config.xdg;
in {
  home-manager.users.${user-info.name}.programs.distrobox = {
    enable = true;
    # NOTE: doesn't work when using podman that is installed only for the user
    #       when fixed, it only creates the missing boxes and doesn't edit the existing ones (thankfully)
    #       just use some variation of: distrobox assemble create --replace --name mybox ~/.config/distrobox/containers.ini
    enableSystemdUnit = false;
    settings = {
      container_additional_volumes = "/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro";
      container_image_default = "docker.io/library/archlinux:latest";
      container_user_custom_home = "${xdg.dataHome}/distrobox/_default_home";
      container_manager = "podman";
    };
    containers = {
      test_arch = {
        entry = true;
        image = "docker.io/library/archlinux:latest";
        home = "${xdg.dataHome}/distrobox/test_arch_home";
        additional_packages = "git base-devel";
        init_hooks = [
          /* bash */ ''sudo -u ${hm-config.home.username} sh -c "cd ~/ && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si --noconfirm && cd .. && sudo rm -r yay-bin"''
        ];
      };
    };
  };
}
