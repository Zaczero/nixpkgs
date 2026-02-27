{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ncursesoflife";
  version = "0-unstable-2014-10-07";

  src = fetchFromGitHub {
    owner = "aftix";
    repo = "NcursesOfLife";
    rev = "0ceeca7c71b9359527f9f4a908d2c6e5b5598004";
    hash = "sha256-aeESQiawqnw8xQhKc5ncyLnU4xaIeQnASt8HMISrSMM=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  buildPhase = ''
    runHook preBuild

    $CC $CPPFLAGS $CFLAGS \
      -o NcursesOfLife \
      Life.c \
      $LDFLAGS -lncurses

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 NcursesOfLife "$out/bin/ncursesoflife"
    install -Dm644 README.md -t "$out/share/doc/${finalAttrs.pname}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Text-based Conway's Game of Life using ncurses";
    homepage = "https://github.com/aftix/NcursesOfLife";
    # No explicit license file in the upstream repository (all rights reserved by default).
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "ncursesoflife";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
