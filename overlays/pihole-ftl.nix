final: prev: {
  # Pin pihole to version with DNSSEC fix: https://github.com/pi-hole/FTL/tree/fix/dnssec-empty-ds-rfc1918-2942
  # issue: https://github.com/pi-hole/FTL/issues/2942
  pihole-ftl = prev.pihole-ftl.overrideAttrs (finalAttrs: prevAttrs: {
    patches = (prevAttrs.patches or []) ++ [
      # Need to use diff because nixos/modules/services/networking/pihole-ftl.nix depends on src.tag
      (prev.fetchpatch2 {
        name = "Fix-dnssec-empty-ds-rfc1918-2942.diff";
        url = "https://github.com/pi-hole/FTL/compare/v6.7...fix/dnssec-empty-ds-rfc1918-2942.diff?full_index=1";
        hash = "sha256-VhvNqif2cMYOcCnfSR+o356GMLD3X3B6bYDVuVfuH9A=";
      })
    ];
  });
}
