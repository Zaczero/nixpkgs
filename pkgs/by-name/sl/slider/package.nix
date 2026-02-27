{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "slider";
  version = "1.0";

  src = fetchurl {
    url = "mirror://ibiblioPubLinux/games/strategy/slider-${finalAttrs.version}.c.gz";
    hash = "sha256-6YKpufgMuIBcIm8s4YAV4pTbRPcNjdBMmJwn40CHPPE=";
  };

  strictDeps = true;

  dontUnpack = true;

  buildInputs = [
    ncurses
  ];

  buildPhase = ''
    runHook preBuild

    gzip -dc "$src" > slider.c
    $CC $CPPFLAGS $CFLAGS -std=gnu89 -Wno-return-mismatch -o slider slider.c $LDFLAGS -lncurses

    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck
    # `slider 0` prints usage and exits successfully.
    ./slider 0 | grep -F "USAGE: slider"
    runHook postCheck
  '';
  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  installPhase = ''
    runHook preInstall
    install -Dm755 slider -t "$out/bin"
    runHook postInstall
  '';

  meta = {
    description = "Ncurses block sliding puzzle";
    homepage = "https://www.ibiblio.org/pub/linux/games/strategy/";
    license = lib.licenses.gpl2Only;
    mainProgram = "slider";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
