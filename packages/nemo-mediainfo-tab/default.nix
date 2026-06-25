{
  stdenvNoCC,
  libmediainfo-py,
  lib,
  fetchFromGitHub,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nemo-mediainfo-tab";
  version = "1.0.4";
  dontBuild = true;

  src = fetchFromGitHub {
    owner = "linux-man";
    repo = "nemo-mediainfo-tab";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5LRDExxCcNQ19LmZQ7uh6OtO1YPQ3BDhWrjqTQBhqiE=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/nemo-python/extensions
    mv ./nemo-extension/* $out/share/nemo-python/extensions

    runHook postInstall
  '';

  passthru.nemoPythonExtensionDeps = [
    libmediainfo-py
  ];

  meta = {
    homepage = "https://github.com/linux-man/nemo-mediainfo-tab";
    description = "View media information from the properties tab in Nemo";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})

