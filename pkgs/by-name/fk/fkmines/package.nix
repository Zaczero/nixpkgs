{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fkmines";
  version = "0.2";

  src = fetchurl {
    url = "mirror://sourceforge/fkmines/Version%20${finalAttrs.version}/fkmines-${finalAttrs.version}.tar.gz";
    hash = "sha256-tPSIdl0Mkq/zajZsBltG7RVxPj2+vcJ+1ZAfXwjbecg=";
  };

  strictDeps = true;

  buildInputs = [ ncurses ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 mines "$out/bin/fkmines"
    install -Dm755 generator "$out/bin/fkmgenerator"

    install -Dm644 README -t "$out/share/doc/fkmines"

    runHook postInstall
  '';

  # Fully curses-based and initializes UI unconditionally, so we can’t test it
  # reliably in a non-interactive build.

  meta = {
    description = "Curses-based minesweeper";
    homepage = "https://sourceforge.net/projects/fkmines/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "fkmines";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
