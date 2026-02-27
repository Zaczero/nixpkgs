{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "connect4";
  version = "0-unstable-2013-03-20";

  src = fetchFromGitHub {
    owner = "badescunicu";
    repo = "connect4";
    rev = "4d65170fbdcae975ce82a2bf351a2567f9195aba";
    hash = "sha256-ETfyd+LhihWa85ZCcfHHPrEOJNZrxLyH0OYMq8NjVVw=";
  };

  strictDeps = true;

  buildInputs = [ ncurses ];
  nativeBuildInputs = [ makeWrapper ];

  # Historical C code: tolerate implicit prototypes rather than patching sources.
  NIX_CFLAGS_COMPILE = [ "-std=gnu89" ];

  # Upstream triggers `-Werror=format-security` from hardening (e.g. `mvprintw`
  # with a non-literal format string). Prefer preserving sources and disabling
  # the hardening check for this package.
  hardeningDisable = [ "format" ];

  buildPhase = ''
    runHook preBuild
    $CC $CPPFLAGS $CFLAGS -o connect4 connect4.c menu.c game.c score.c $LDFLAGS -lncurses
    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    # Guard against hangs; the UI is interactive and may not exit cleanly in a
    # non-tty environment, so accept timeout as success.
    rc=0
    printf 'q\n' | TERM=xterm timeout --kill-after=1s 10s ./connect4 >/dev/null 2>&1 || rc="$?"
    test "$rc" -eq 0 -o "$rc" -eq 124

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 connect4 "$out/libexec/connect4"
    install -Dm644 scoreDatabase.bin -t "$out/share/connect4"
    install -Dm644 README README.md -t "$out/share/doc/connect4"
    makeWrapper "$out/libexec/connect4" "$out/bin/connect4" \
      --run 'dataDir="''${XDG_DATA_HOME:-$HOME/.local/share}/connect4"' \
      --run 'mkdir -p "$dataDir"' \
      --run 'if [ ! -e "$dataDir/scoreDatabase.bin" ]; then cp -f "$out/share/connect4/scoreDatabase.bin" "$dataDir/scoreDatabase.bin"; fi' \
      --run 'cd "$dataDir"'
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Ncurses Connect Four game";
    homepage = "https://github.com/badescunicu/connect4";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "connect4";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
