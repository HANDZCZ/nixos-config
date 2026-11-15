# Use unstable package, with beta version that supports TLS inspection
final: prev: let
  version = "2026.9.2663.1";

  unstable-pkg = final.pkgs-unstable.cloudflare-warp;
  check = final.lib.versionAtLeast unstable-pkg.version version;

  pinned-cloudflare-warp = unstable-pkg.overrideAttrs (old: {
    inherit version;
    src = final.fetchurl {
      name = "cloudflare-warp_${version}_amd64.deb";
      url = "https://downloads.cloudflareclient.com/v1/download/noble-intel/version/${version}";
      hash = "sha256-9xselQBajYy/AN/36mWygNzhwQLY+oPTWkhhulxvhAU=";
    };
  });
in {
  cloudflare-warp = final.lib.warnIf check "cloudflare-warp version is >= ${version}" pinned-cloudflare-warp;
}
