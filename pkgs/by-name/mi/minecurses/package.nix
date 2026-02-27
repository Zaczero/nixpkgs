{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "minecurses";
  version = "0-unstable-2014-11-25";

  src = fetchFromGitHub {
    owner = "EliteTK";
    repo = "minecurses";
    rev = "dbbff0eb8bd7f5a404f0a8fa11fcafbf1d826a80";
    hash = "sha256-aOSKl4oq5CyEYmh9wrEbPvh6i1WtsW0M4vBzlNOmPmo=";
  };

  strictDeps = true;

  buildInputs = [ ncurses ];

  postPatch = ''
    # Fix UB: `c` was used uninitialized in the option parsing loop.
    substituteInPlace src/main.c \
      --replace-fail 'int c;' 'int c = 0;'
  '';

  buildPhase = ''
    runHook preBuild

    make \
      CC=${stdenv.cc.targetPrefix}cc \
      CFLAGS="$CFLAGS -c -Wall -Wno-error" \
      LDFLAGS="$LDFLAGS -lncurses -lm"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 minecurses -t "$out/bin"
    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 "$src/README.md" -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 "$src/LICENSE" -t "$out/share/licenses/${finalAttrs.pname}"
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    output="$(./minecurses -h 2>&1 || :)"
    grep -Fq "Usage: minecurses" <<<"$output"

    runHook postCheck
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Curses-based minesweeper";
    homepage = "https://github.com/EliteTK/minecurses";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "minecurses";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
