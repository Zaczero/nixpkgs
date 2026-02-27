{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ship_game";
  version = "0-unstable-2014-07-17";

  src = fetchFromGitHub {
    owner = "FedeDP";
    repo = "ship_game";
    rev = "3fd7294e91cfd215b942a10f9b1bff08d1c38277";
    hash = "sha256-RBqQznj0tLjR6xjFUMEykrTgvzUUgjndCx+os+y2at8=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  buildPhase = ''
    runHook preBuild

    $CC -o ship_battle ship_battle.c -lncurses

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 ship_battle -t "$out/bin"
    install -Dm644 README.md -t "$out/share/doc/${finalAttrs.pname}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Pseudo-classical ships shooting game written in C and ncurses";
    homepage = "https://github.com/FedeDP/ship_game";
    # The upstream repo snapshot contains a `PKGBUILD` claiming `GPL3`, but no
    # license text or author-provided license grant for the sources themselves.
    # Treat as all-rights-reserved.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "ship_battle";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
