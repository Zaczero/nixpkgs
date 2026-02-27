{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  python3,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sqlite-hangman";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "mateusza";
    repo = "sqlite-hangman";
    rev = "v${finalAttrs.version}";
    hash = "sha256-BnYw1YK9ReNhSbYewhVltCslLb7qhRC6XuXNgQt/xnc=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    tmpdir=$(mktemp -d)
    cp hangman.sql "$tmpdir/hangman.sql"
    ${lib.getExe sqlite} "$tmpdir/hangman.db" < "$tmpdir/hangman.sql"
    ${lib.getExe sqlite} "$tmpdir/hangman.db" 'select * from game;' | grep -Fq "SQLite Hangman"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 hangman.sql -t "$out/share/${finalAttrs.pname}"
    install -Dm644 hangman.html -t "$out/share/${finalAttrs.pname}"
    install -Dm755 webhangman.py -t "$out/share/${finalAttrs.pname}"

    makeWrapper ${lib.getExe sqlite} "$out/bin/sqlite-hangman" \
      --set SQLITE_HANGMAN_SQL "$out/share/${finalAttrs.pname}/hangman.sql" \
      --run 'dbdir="''${SQLITE_HANGMAN_DIR:-$PWD}"' \
      --run 'test -e "$dbdir/hangman.db" || ${lib.getExe sqlite} "$dbdir/hangman.db" < "$SQLITE_HANGMAN_SQL"' \
      --add-flags '"$dbdir/hangman.db"'

    makeWrapper ${lib.getExe python3} "$out/bin/sqlite-hangman-web" \
      --set SQLITE_HANGMAN_SQL "$out/share/${finalAttrs.pname}/hangman.sql" \
      --set SQLITE_HANGMAN_HTML "$out/share/${finalAttrs.pname}/hangman.html" \
      --set SQLITE_HANGMAN_PY "$out/share/${finalAttrs.pname}/webhangman.py" \
      --run 'dbdir="''${SQLITE_HANGMAN_DIR:-$PWD}"' \
      --run 'cp -f "$SQLITE_HANGMAN_SQL" "$dbdir/hangman.sql"' \
      --run 'cp -f "$SQLITE_HANGMAN_HTML" "$dbdir/hangman.html"' \
      --run 'cp -f "$SQLITE_HANGMAN_PY" "$dbdir/webhangman.py"' \
      --chdir "$dbdir" \
      --add-flags "$dbdir/webhangman.py"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Hangman game implemented in SQLite (plus an optional tiny web UI)";
    homepage = "https://github.com/mateusza/sqlite-hangman";
    license = lib.licenses.mit;
    mainProgram = "sqlite-hangman";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
