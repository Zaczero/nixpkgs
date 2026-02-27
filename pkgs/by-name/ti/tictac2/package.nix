{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tictac2";
  version = "0.6";

  src = fetchurl {
    url = "mirror://ibiblioPubLinux/games/strategy/tictac2-${finalAttrs.version}.tgz";
    hash = "sha256-vAHl7PqCWRhOM1RK6hHCdKrGW1n33IC66F1n7qmr96A=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    ncurses
  ];

  NIX_CFLAGS_COMPILE = [
    "-std=gnu89"
    "-Wno-implicit-function-declaration"
    "-include"
    "stdlib.h"
    "-include"
    "strings.h"
  ];

  postPatch = ''
    rm *.o
  '';

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "LIBS=-lncurses"
    "LIBS+=-ltinfo"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 tictac2 -t "$out/bin"
    installManPage tictac2.6

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 README.license -t $out/share/licenses/${finalAttrs.pname}/COPYING
  '';

  meta = {
    description = "Two-player or CPU Tic-Tac-Toe game (ncurses)";
    homepage = "https://www.ibiblio.org/pub/linux/games/strategy/";
    license = lib.licenses.gpl2Plus;
    mainProgram = "tictac2";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
