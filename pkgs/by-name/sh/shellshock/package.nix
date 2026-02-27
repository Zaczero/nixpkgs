{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "shellshock";
  version = "1.16";

  src = fetchurl {
    url = "https://dhampir.no/stuff/bash/shellshock.bash";
    hash = "sha256-RIlnV/2JtabBZvpSDK+q1azVphWoVJeExa1Ocl3WPMI=";
  };

  strictDeps = true;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/${finalAttrs.pname}"

    runHook postInstall
  '';

  doCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  checkPhase = ''
    runHook preCheck

    ${stdenvNoCC.shellDryRun} "$src"

    runHook postCheck
  '';

  meta = {
    description = "Top-down space shooter written in Bash";
    homepage = "https://dhampir.no/stuff/bash/shellshock";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "shellshock";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
