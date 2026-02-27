{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
  zlib,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sudognu";
  version = "1.09";

  src = fetchurl {
    url = "mirror://sourceforge/sudognu/sudognu/sudognu-${finalAttrs.version}/sudognu-${finalAttrs.version}.tar.gz";
    hash = "sha256-Ry1erA+ZLYo8J/OYmKeGSEvmCYH13d8l4M4xTWIwJSM=";
    name = "${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    zlib
  ];

  buildPhase = ''
    runHook preBuild

    $CC $CPPFLAGS $CFLAGS -I. -Wall -c *.c
    $CC $CFLAGS *.o $LDFLAGS -o sudognu -lm -lz -lpthread

    runHook postBuild
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  versionCheckProgramArg = "-V";

  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/sudognu" -h >/dev/null
    runHook postInstallCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 sudognu -t "$out/bin"
    installManPage sudognu.1

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 COPYING -t $out/share/licenses/${finalAttrs.pname}
  '';

  meta = {
    description = "Command-line Sudoku solver and generator";
    homepage = "http://baaran.de/sudoku/index-en.shtml";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
    mainProgram = "sudognu";
  };
})
