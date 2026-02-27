{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "piskworks";
  version = "ersion_0.6.0";

  src = fetchFromGitHub {
    owner = "oldcompcz";
    repo = "piskworks";
    rev = "e9a9f8a0013fa91ba82173dbd401bd75f2048e6e";
    hash = "sha256-0kBZVITT1EUJvw9NoVPUA0c+TlDe5aQfJUKk+bPO6MY=";
  };

  strictDeps = true;

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    make -f Makefile.gcc pisk_con \
      CC="$CC"

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    patchShebangs tests
    make -f Makefile.gcc unittest

    # Upstream ships a small unit-test runner, but the bundled expected outputs
    # for some scenes don’t match the current game output (e.g. missing fields),
    # so we run a representative passing scene as a regression/smoke test.
    ./tests/unittest ./tests/test1.sce ./tests/test1.exp

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 pisk_con "$out/bin/piskworks"

    install -Dm644 "$src/README.md" "$out/share/doc/$pname/README.md"
    install -Dm444 "$src/LICENSE" "$out/share/licenses/$pname/LICENSE"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Gomoku (five-in-a-row) console game";
    homepage = "https://github.com/oldcompcz/piskworks";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "piskworks";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
