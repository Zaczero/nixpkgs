{
  lib,
  stdenv,
  fetchurl,
  ncompress,
  makeWrapper,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yahtzee";
  version = "1992-01-25";

  src = fetchurl {
    url = "mirror://ibiblioPubLinux/games/strategy/yahtzee-src.tar.Z";
    hash = "sha256-gkXQX8JYcMYnlDeK7+7LxfaHtjL5S0efLsCcQqoqJSs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ncompress
    makeWrapper
  ];

  buildInputs = [
    ncurses
  ];

  hardeningDisable = [
    "format"
  ];

  unpackPhase = ''
    runHook preUnpack
    uncompress -c "$src" | tar -xf -
    sourceRoot="yahtzee"
    runHook postUnpack
  '';

  postPatch = ''
    # The upstream defaults to system-wide score directories. For a nixpkgs
    # package we instead keep scores in the current working directory, and use
    # a wrapper to run from a per-user state directory.
    substituteInPlace config.h \
      --replace-fail '#define SCOREDIR "/usr/local/lib"' '#define SCOREDIR "."'
  '';

  buildPhase = ''
    runHook preBuild

    $CC $CPPFLAGS $CFLAGS -std=gnu89 -Wno-implicit-int -Wno-implicit-function-declaration \
      -fno-builtin-abort \
      -o yahtzee \
      computer.c main.c \
      $LDFLAGS -lncurses -ltinfo

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    # `-s` prints the scoreboard and avoids the curses UI.
    output="$(printf '\n' | ./yahtzee -s)"
    grep -Fq "Yahtzee top scores" <<<"$output"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 yahtzee "$out/libexec/yahtzee"
    makeWrapper "$out/libexec/yahtzee" "$out/bin/yahtzee" \
      --run 'stateDir="''${XDG_STATE_HOME:-$HOME/.local/state}/yahtzee"' \
      --run 'mkdir -p "$stateDir"' \
      --run 'cd "$stateDir"'

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README -t $out/share/doc/${finalAttrs.pname}
  '';

  meta = {
    description = "Curses-based Yahtzee";
    homepage = "https://www.ibiblio.org/pub/linux/games/strategy/";
    # No license file/notice found for the game sources in the archive.
    license = lib.licenses.unfree;
    mainProgram = "yahtzee";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
