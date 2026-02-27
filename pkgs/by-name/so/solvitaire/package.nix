{
  lib,
  stdenv,
  fetchgit,
  ncurses,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "solvitaire";
  version = "0-unstable-2022-05-19";

  src = fetchgit {
    url = "https://git.gir.st/solVItaire.git";
    rev = "1883ee0c67f3e5f7807f7a886333360e31f804be";
    hash = "sha256-AzH1rZFqEH8sovZZfJykvsEmCedEZWigQFHWHl6/PdE=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    ./sol -h 2>&1 | grep -Fq "Keybindings"
    ./spider -h 2>&1 | grep -Fq "Keybindings"
    ./freecell -h 2>&1 | grep -Fq "Keybindings"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 sol -t "$out/bin"
    install -Dm755 spider -t "$out/bin"
    install -Dm755 freecell -t "$out/bin"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 LICENSE -t $out/share/licenses/${finalAttrs.pname}
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://git.gir.st/solVItaire.git";
    hardcodeZeroVersion = true;
  };

  meta = {
    description = "Klondike, Spider, and FreeCell solitaire for the terminal";
    homepage = "https://gir.st/sol.html";
    license = lib.licenses.gpl3Only;
    mainProgram = "sol";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
