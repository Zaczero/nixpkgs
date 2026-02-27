{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cryptoslam";
  version = "1.2";

  src = fetchurl {
    url = "mirror://sourceforge/cryptoslam/cryptoslam/cryptoslam-${finalAttrs.version}/cryptoslam-${finalAttrs.version}.tgz";
    hash = "sha256-dWGxcA2QWrs19iOucwa9dbXk3oxp/pvxt8ZoF0M5J0g=";
  };

  strictDeps = true;

  buildInputs = [ ncurses ];

  buildPhase = ''
    runHook preBuild
    $CXX $CPPFLAGS $CXXFLAGS -c cryptogram.cpp
    $CXX $CPPFLAGS $CXXFLAGS -c cryptoslam.cpp
    $CXX -o cryptoslam cryptogram.o cryptoslam.o $LDFLAGS -lncurses
    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    mkdir -p "$TMPDIR/home"
    TERM=xterm HOME="$TMPDIR/home" timeout --kill-after=1s 10s ./cryptoslam >/dev/null 2>&1 || test "$?" -eq 124

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 cryptoslam -t "$out/bin"
    install -Dm644 CHANGELOG README sample.txt -t "$out/share/doc/${finalAttrs.pname}"
    runHook postInstall
  '';

  meta = {
    description = "Curses-based tool for solving substitution cryptograms";
    homepage = "https://sourceforge.net/projects/cryptoslam/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "cryptoslam";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
