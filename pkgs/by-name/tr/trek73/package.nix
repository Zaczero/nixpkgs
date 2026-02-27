{
  lib,
  stdenv,
  fetchurl,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "trek73";
  version = "unstable-1990-11";

  src = fetchurl {
    url = "http://highlandsun.com/hyc/trek73c.tgz";
    hash = "sha256-XW9Co1ImJTF49PG3iDBFwdgsutWf2M6cFuJOHte6qbk=";
  };

  strictDeps = true;

  sourceRoot = ".";

  buildInputs = [
    ncurses
  ];

  NIX_CFLAGS_COMPILE = [
    "-std=gnu89"
    "-Wno-implicit-int"
    "-Wno-implicit-function-declaration"
  ];

  postPatch = ''
    substituteInPlace Makefile --replace-fail $'\r' ""

    substituteInPlace trekx.c \
      --replace-fail "char *malloc();" "" \
      --replace-fail "WINDOW *Twin, *subwin();" "WINDOW *Twin;" \
      --replace-fail "#include <unistd.h>" $'#include <unistd.h>\n#include <stdlib.h>'
  '';

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "LIBS=-lncurses"
    "LIBS+=-lm"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 trekx -t "$out/bin"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=skip" ];

  };
  meta = {
    description = "Star Trek space-battle simulation (curses, 1990 C version)";
    homepage = "https://kermitmurray.com/trek73/";
    # The source header says "All rights reserved".
    license = lib.licenses.unfree;
    mainProgram = "trekx";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
