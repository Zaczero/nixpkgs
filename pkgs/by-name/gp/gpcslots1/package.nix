{
  lib,
  stdenv,
  fetchurl,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpcslots1";
  version = "1.0";

  src = fetchurl {
    url = "mirror://sourceforge/gpcslots1/gpcslots";
    hash = "sha256-oEn2NiAtvIngYPV1Zs8F/deyydxVRQuhnOdWAl+8vJM=";
  };

  strictDeps = true;

  dontUnpack = true;

  nativeBuildInputs = [ perl ];
  nativeCheckInputs = [ perl ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck
    output=$(
      ${lib.getExe perl} -e 'alarm 2; do $ARGV[0];' $src <<< $'1\nexit\nexit\n' || true
    )
    grep -Fq "GP-CASINO" <<<"$output"
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/gpcslots
    patchShebangs $out/bin/gpcslots
    runHook postInstall
  '';

  meta = {
    description = "Text-based single-slot casino game";
    homepage = "https://sourceforge.net/projects/gpcslots1/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "gpcslots";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
