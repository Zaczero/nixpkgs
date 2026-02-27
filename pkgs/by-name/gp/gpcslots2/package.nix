{
  lib,
  stdenv,
  fetchurl,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpcslots2";
  version = "0.4.5b";

  src = fetchurl {
    url = "mirror://sourceforge/gpcslots2/gpcslots2_0-4-5b";
    hash = "sha256-Ta9bbloj/mzRIf4SUPEK2fO5Nr1TbUdexYX1eZhzb1U=";
  };

  strictDeps = true;

  dontUnpack = true;

  nativeBuildInputs = [ perl ];
  nativeCheckInputs = [ perl ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck
    ${lib.getExe perl} $src --help | grep -Fq "GPCSLOTS 2"
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/gpcslots2
    patchShebangs $out/bin/gpcslots2
    runHook postInstall
  '';

  meta = {
    description = "Text-based casino game with slots and table games";
    homepage = "https://sourceforge.net/projects/gpcslots2/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "gpcslots2";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
