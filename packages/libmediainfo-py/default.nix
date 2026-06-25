{
  python3Packages,
  lib,
  libmediainfo,
  ...
}:

let
  py-pkgs-loc = python3Packages.python.sitePackages;
in python3Packages.buildPythonPackage (finalAttrs: {
  pname = "libmediainfo-py";
  version = libmediainfo.version;
  pyproject = false;

  src = libmediainfo.src;
  sourceRoot = "MediaInfoLib/Source/MediaInfoDLL";

  dependecies = [
    libmediainfo
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/${py-pkgs-loc}
    install -m 644 MediaInfoDLL*.py $out/${py-pkgs-loc}

    runHook postInstall
  '';

  patchPhase = ''
    runHook prePatch

    substituteInPlace MediaInfoDLL*.py \
      --replace-fail "libmediainfo.so.0" "${libmediainfo}/lib/libmediainfo.so.0"

    runHook postPatch
  '';

  meta = {
    description = "Shared library for mediainfo - python integration";
    homepage = "https://mediaarea.net/";
    changelog = "https://mediaarea.net/MediaInfo/ChangeLog";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.unix;
  };
})

