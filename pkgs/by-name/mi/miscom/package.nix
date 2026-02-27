{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "miscom";
  version = "1.0";

  src = fetchurl {
    url = "https://slackware.uk/sbosrcarch/by-name/games/miscom/miscom.tar.gz";
    hash = "sha256-M3eOgwLLtSfnBA6VO89e4YW3pSRFVVLj4J7BtTICjjY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
  ];

  postPatch = ''
    substituteInPlace unix.c \
      --replace-fail 'void bombout()' 'void bombout(int signum)'
    substituteInPlace unix.h \
      --replace-fail 'extern void bombout(void);' 'extern void bombout(int signum);'
    substituteInPlace fire.c \
      --replace-fail 'bombout();' 'bombout(0);'
    substituteInPlace main.c \
      --replace-fail 'bombout();' 'bombout(0);'
  '';

  buildInputs = [
    ncurses
  ];

  # Interactive curses game; no non-interactive self-test mode.

  buildPhase = ''
    runHook preBuild

    $CC \
      $NIX_CFLAGS_COMPILE \
      -I. \
      -I${lib.getDev ncurses}/include \
      -include string.h \
      -include stdlib.h \
      -o miscom \
      *.c \
      -lncurses

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 miscom -t "$out/bin"
    installManPage miscom.6
    install -Dm644 sounds/* -t "$out/share/${finalAttrs.pname}/sounds"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README ChangeLog -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 COPYING -t "$out/share/licenses/${finalAttrs.pname}"
  '';

  meta = {
    description = "Curses-based missile command clone";
    homepage = "https://slackware.uk/sbosrcarch/by-name/games/miscom/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "miscom";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
