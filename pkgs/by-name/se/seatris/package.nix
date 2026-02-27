{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "seatris";
  version = "0.0.14";

  src = fetchurl {
    url = "https://www.earth.li/projectpurple/files/seatris-${finalAttrs.version}.tar.gz";
    hash = "sha256-eX7BQD3sLmx5Dsd9QbxSAQVc++9NmtcFQnCEXJCdCi4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    ncurses
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    cat > autoconf.h <<'EOF'
    #pragma once
    #define NCURSES 1
    #define HAVE_NCURSES_H 1
    #define STDC_HEADERS 1
    #define HAVE_STDLIB_H 1
    #define HAVE_UNISTD_H 1
    #define HAVE_GETOPT_H 1
    #define HAVE_SELECT 1
    #define HAVE_STRDUP 1
    #define HAVE_SYS_TIME_H 1
    #define TIME_WITH_SYS_TIME 1
    EOF

    $CC \
      -Wall \
      -pedantic \
      $NIX_CFLAGS_COMPILE \
      -c \
      seatris.c blockstuff.c disp_ncurses.c fieldstuff.c scoring.c parse.c readcfg.c

    $CC -o seatris *.o -lncurses

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 seatris -t "$out/bin"
    installManPage seatris.6

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README HISTORY ACKNOWLEDGEMENTS example.seatrisrc -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 LICENSE -t $out/share/licenses/${finalAttrs.pname}
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck

    ./seatris -h > /dev/null || [ "$?" -eq 1 ]

    runHook postCheck
  '';

  meta = {
    description = "Ncurses-based Tetris clone";
    homepage = "https://www.earth.li/projectpurple/progs/seatris.html";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "seatris";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
