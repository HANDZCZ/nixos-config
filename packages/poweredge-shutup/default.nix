{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  ipmitool,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "poweredge-shutup";
  version = "git-${lib.sources.shortRev finalAttrs.src.rev}";
  dontBuild = true;

  src = fetchFromGitHub {
    owner = "HANDZCZ";
    repo = "PowerEdge-shutup";
    rev = "260537c8fbbe552a77d28ad82786ada51d4a09f7";
    hash = "sha256-dqfODekXNuWun5KJb9LLYWJ3VTEjVR2walOwiWtbZok=";
  };

  postPatch = ''
    patchShebangs ./fancontrol.sh
    substituteInPlace ./fancontrol.sh \
      --replace-fail "ipmitool" ${lib.getExe ipmitool}
  '';

  installPhase = ''
    runHook preInstall

    install -Dm 755 fancontrol.sh $out/bin/dell-fancontrol

    runHook postInstall
  '';

  meta = {
    homepage = "PowerEdge-shutup";
    description = "Program for controlling fan speed on dell servers";
    platforms = lib.platforms.linux;
    mainProgram = "dell-fancontrol";
  };
})

