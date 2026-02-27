{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
  makeWrapper,
  ncurses,
  ncompress,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "moria";
  version = "4.87";

  src = fetchurl {
    url = "https://www.funet.fi/pub/unix/games/moria/source/moria487.tar.Z";
    hash = "sha256-ZZMedDeVxPhOa+Skbw6YbZmD5VLn4qERu3HBiMtsUTA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    ncompress
  ];

  buildInputs = [
    ncurses
  ];

  unpackPhase = ''
    runHook preUnpack

    uncompress -c "$src" | tar xf -

    runHook postUnpack
  '';

  postPatch = ''
    # Upstream's config hardcodes absolute paths and assumes a setuid install.
    # In nixpkgs we keep the game non-setuid and use a wrapper that runs from a
    # per-user state directory.
    substituteInPlace config.h \
      --replace-fail "/* #define NO_SIGNED_CHARS" "/* #define NO_SIGNED_CHARS */"

    substituteInPlace config.h \
      --replace-fail '#define MORIA_HOU  "/usrb/vopata/mm/Moria_hours"' '#define MORIA_HOU  "'"$out"'/share/moria/Moria_hours"' \
      --replace-fail '#define MORIA_MOR  "/usrb/vopata/mm/Moria_news"' '#define MORIA_MOR  "'"$out"'/share/moria/Moria_news"' \
      --replace-fail '#define MORIA_TOP  "/usrb/vopata/mm/Highscores"' '#define MORIA_TOP  "Highscores"'

    # Fix for modern libc headers: avoid redeclaring `signal(3)` and don't
    # register handlers for signals that don't exist on glibc/Linux.
    substituteInPlace signals.c \
      --replace-fail "int (*signal())();" "" \
      --replace-fail "  (void) signal(SIGEMT, signal_save_core);" ""

    # Avoid conflicting with libc's `remove(3)` declaration from stdio.h.
    substituteInPlace moria1.c \
      --replace-fail "remove(" "remove_item("

    # Build fixes for modern GCC/linkers.
    substituteInPlace Makefile \
      --replace-fail "-lcurses -ltermcap" "-lncurses -ltinfo"
  '';

  NIX_CFLAGS_COMPILE = [
    "-std=gnu89"
    "-Wno-implicit-int"
    "-Wno-implicit-function-declaration"
    "-DUSG"
    "-fcommon"
  ];

  buildPhase = ''
    runHook preBuild
    make moria CC=${stdenv.cc.targetPrefix}cc
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 moria -t "$out/libexec"

    install -Dm644 Highscores -t "$out/share/moria"
    install -Dm444 Moria_hours -t "$out/share/moria"
    install -Dm444 Moria_news -t "$out/share/moria"

    install -Dm644 README M.doc Moria.doc.1 Moria.doc.2 Moria.man.alt -t "$out/share/doc/${finalAttrs.pname}"
    installManPage --name moria.6 Moria.man

    makeWrapper "$out/libexec/moria" "$out/bin/moria" \
      --run 'stateDir="''${XDG_STATE_HOME:-$HOME/.local/state}/moria"; mkdir -p "$stateDir"; if [ ! -e "$stateDir/Highscores" ]; then cp -f "$out/share/moria/Highscores" "$stateDir/Highscores"; fi; cd "$stateDir"'

    runHook postInstall
  '';

  meta = {
    description = "Classic roguelike game Moria (historical 4.87 release)";
    homepage = "https://www.funet.fi/pub/unix/games/moria/";
    # Upstream tarball does not include a license statement; treat as all-rights-reserved.
    license = lib.licenses.unfree;
    mainProgram = "moria";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
