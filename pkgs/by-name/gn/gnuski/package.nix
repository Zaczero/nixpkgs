{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnuski";
  version = "0.3";

  src = fetchurl {
    url = "mirror://sourceforge/gnuski/gnuski/gnuski-${finalAttrs.version}/gnuski-${finalAttrs.version}.tar.gz";
    hash = "sha256-G2Kb0p3WrTYrVgVczbTHrUYv8516DeuRV1PCCW9flZ0=";
  };

  strictDeps = true;

  buildInputs = [ ncurses ];

  buildPhase = ''
    runHook preBuild
    $CC $CPPFLAGS $CFLAGS \
      -std=gnu89 \
      -Wno-implicit-function-declaration \
      -o gnuski main.c objects.c \
      $LDFLAGS -lncurses
    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck
    TERM=xterm timeout --kill-after=1s 10s ./gnuski >/dev/null 2>&1 || test "$?" -eq 124
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 gnuski -t "$out/bin"
    install -Dm644 readme -t "$out/share/doc/${finalAttrs.pname}"
    runHook postInstall
  '';

  meta = {
    description = "Ncurses clone of the classic Skifree game";
    homepage = "https://sourceforge.net/projects/gnuski/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "gnuski";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
