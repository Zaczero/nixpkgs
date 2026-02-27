{
  lib,
  stdenv,
  fetchFromGitHub,
  gnumake,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "berk76-tetris";
  version = "ersion_1.1.0";

  src = fetchFromGitHub {
    owner = "oldcompcz";
    repo = "tetris";
    rev = "31d441a840dff7ad3839087b9a5a594250841342";
    hash = "sha256-B5IYXT6Z3zbeG9lG7rflQvFnvOI/vse6L2Orv5dWlHg=";
  };

  strictDeps = true;

  nativeBuildInputs = [ gnumake ];
  buildInputs = [ ncurses ];

  buildPhase = ''
    runHook preBuild

    make -f Makefile.con CC=${stdenv.cc.targetPrefix}cc

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    # The ncurses UI is interactive; smoke-test that we can start and reach
    # the quit path ("Good Bye") without hanging the build.
    output="$(TERM=xterm timeout 3s sh -c 'printf qqqq | ./Tetris' || true)"
    grep -Fq "Good Bye" <<<"$output"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 Tetris "$out/bin/${finalAttrs.pname}"
    install -Dm644 README.md LICENSE -t "$out/share/doc/${finalAttrs.pname}"
    cp -a doc "$out/share/doc/${finalAttrs.pname}/doc"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Console Tetris game (ncurses)";
    homepage = "https://github.com/oldcompcz/tetris";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "berk76-tetris";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
