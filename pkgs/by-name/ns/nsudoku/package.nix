{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nsudoku";
  version = "1.3";

  src = fetchurl {
    url = "https://www.tbmatuka.com/nsudoku/nsudoku.c";
    hash = "sha256-lZXUSd3po7k7+vP2/bOuJmkAiTX+kCvXP3Qsga9ru6Q=";
  };

  strictDeps = true;

  dontUnpack = true;

  buildInputs = [
    ncurses
  ];

  buildPhase = ''
    runHook preBuild

    $CC $CPPFLAGS $CFLAGS -o nsudoku "$src" $LDFLAGS -lncurses

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 nsudoku -t "$out/bin"
    install -Dm644 "$src" -T "$out/share/doc/${finalAttrs.pname}/nsudoku.c"

    install -d "$out/share/licenses/${finalAttrs.pname}"
    # The upstream source file includes the full MIT license text in its
    # header comment; extract it for the canonical nixpkgs licenses location.
    sed -n '1,/^\*\//p' "$src" > "$out/share/licenses/${finalAttrs.pname}/LICENSE"

    runHook postInstall
  '';

  # Interactive curses program; no non-interactive mode.

  meta = {
    description = "Sudoku game for the terminal";
    homepage = "https://www.tbmatuka.com/nsudoku/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "nsudoku";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
