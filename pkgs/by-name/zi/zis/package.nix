{
  lib,
  stdenv,
  fetchurl,
  ncurses,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zis";
  version = "0.99.5";

  src = fetchurl {
    name = "zis-${finalAttrs.version}.tar.gz";
    url = "mirror://sourceforge/zis/zis/${finalAttrs.version}/zis-${finalAttrs.version}.tar.gz";
    hash = "sha256-ijrsvSIZsByhRV1yqwoKSMXB4szRf/PLkmdJCq/GZ8M=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  hardeningDisable = [
    "format"
  ];

  buildPhase = ''
    runHook preBuild

    $CC $CPPFLAGS $CFLAGS -std=gnu89 -Wno-implicit-function-declaration \
      -fcommon \
      -c game.c ai.c ui.c aa.c

    $CC -o zis game.o ai.o ui.o aa.o \
      $LDFLAGS -lncurses -lmenu -lpanel -ltinfo -lm

    runHook postBuild
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  versionCheckProgramArg = "--version";

  installPhase = ''
    runHook preInstall
    install -Dm755 zis -t "$out/bin"
    install -Dm644 README -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 help.html -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 LICENSE -t "$out/share/licenses/${finalAttrs.pname}"

    # Keep a stable, game-specific lookup location as well.
    install -d "$out/share/zis"
    ln -s ../doc/${finalAttrs.pname}/help.html "$out/share/zis/help.html"
    runHook postInstall
  '';

  meta = {
    description = "Curses multiplayer space strategy game (Konquest-like)";
    homepage = "https://sourceforge.net/projects/zis/";
    license = lib.licenses.mit;
    mainProgram = "zis";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
