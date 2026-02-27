{
  lib,
  stdenv,
  fetchurl,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "duelcommander";
  version = "0.2.1.1";

  src = fetchurl {
    url = "mirror://sourceforge/duelcommander/Stable/Duel%20Commander%20${finalAttrs.version}/DuelCommander-${finalAttrs.version}_linux.tar.bz2";
    hash = "sha256-r6werJ1ZyQae0rgiu2rC4TmLw3dEXB0cDGyH/gFmIFo=";
  };

  strictDeps = true;

  buildPhase = ''
    runHook preBuild

    $CC $CPPFLAGS $CFLAGS -Wall \
      -o duelcommander \
      src/main.c src/random.c src/ai.c \
      $LDFLAGS

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    # Quit from the main menu immediately.
    timeout 10s sh -c 'printf "\n3\n" | ./duelcommander >/dev/null'

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 duelcommander -t "$out/bin"
    install -Dm644 README doc/* -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 pixmaps/duelcommander.png -t "$out/share/pixmaps"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=skip" ];

  };
  meta = {
    description = "Turn-based command-line fighting game";
    homepage = "https://sourceforge.net/projects/duelcommander/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "duelcommander";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
