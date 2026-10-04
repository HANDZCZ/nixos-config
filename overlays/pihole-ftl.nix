final: prev: {
  # Patch pihole so DNSSEC in rev routes does not return SERVFAIL
  # issue: https://github.com/pi-hole/FTL/issues/2942
  pihole-ftl = prev.pihole-ftl.overrideAttrs (finalAttrs: prevAttrs: {
    patches = (prevAttrs.patches or []) ++ [
      # prerequisite update
      (prev.fetchpatch2 {
        name = "Pihole-ftl-update-dnsmasq-to-v2.93+16.diff";
        url = "https://patch-diff.githubusercontent.com/raw/pi-hole/FTL/pull/3018.diff?full_index=1";
        hash = "sha256-cjvOORWoC+eLftMXGspfnO7DqvxPpU7R8NeIk55jvwM=";
      })
      # update caring the fix
      (prev.fetchpatch2 {
        name = "Pihole-ftl-update-dnsmasq-to-v2.93+30.diff";
        url = "https://patch-diff.githubusercontent.com/raw/pi-hole/FTL/pull/3103.diff?full_index=1";
        hash = "sha256-SKsvzwQ0QlPtJKdp4dMpp4iOi6vRi0Ft+u1Te3OBago=";
      })
    ];
  });
}
