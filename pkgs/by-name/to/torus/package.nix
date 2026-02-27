{
  lib,
  stdenv,
  fetchurl,
  ncompress,
  makeWrapper,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "torus";
  version = "1992-03-06";

  src = fetchurl {
    url = "mirror://ibiblioPubLinux/games/arcade/torus-src.tar.Z";
    hash = "sha256-9e0PkKtclbgwqynI4vXp+0jh6FzjfTd75uA9XhN03n0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ncompress
    makeWrapper
  ];

  buildInputs = [
    ncurses
  ];

  unpackPhase = ''
    runHook preUnpack
    uncompress -c "$src" | tar -xf -
    sourceRoot="torus"
    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild

    # Avoid hardcoded global score locations by using relative filenames; the
    # wrapper script will create these in a per-user state directory.
    $CC $CPPFLAGS $CFLAGS \
      -std=gnu89 \
      -Wno-builtin-declaration-mismatch \
      -Wno-implicit-int -Wno-implicit-function-declaration \
      -Wno-return-type \
      '-DEXFUN(name,proto)=name proto' \
      -DHOF_FILE='"robots2_hof"' \
      -DTMP_FILE='"robots2_tmp"' \
      -DT_HOF_FILE='"torus_hof"' \
      -DT_TMP_FILE='"torus_tmp"' \
      -o torus \
      good.c main.c opt.c robot.c score.c user.c \
      $LDFLAGS -lncurses -ltinfo

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    # The program is interactive, but it reads from stdin sufficiently to smoke
    # test startup and a clean exit.
    TERM=xterm printf 'q' | ./torus >/dev/null

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 torus "$out/libexec/torus"
    makeWrapper "$out/libexec/torus" "$out/bin/torus" \
      --run 'stateDir="''${XDG_STATE_HOME:-$HOME/.local/state}/torus"' \
      --run 'mkdir -p "$stateDir"' \
      --run 'cd "$stateDir"' \
      --run ': >> robots2_hof' \
      --run ': >> robots2_tmp' \
      --run ': >> torus_hof' \
      --run ': >> torus_tmp'

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README.linux -t $out/share/doc/${finalAttrs.pname}
  '';

  meta = {
    description = "Robots-like curses game on a torus-shaped playfield";
    homepage = "https://www.ibiblio.org/pub/linux/games/arcade/";
    # The source header in `main.c` includes a non-commercial restriction:
    # "Provided free as long as you don't make money from it!".
    license = lib.licenses.unfree;
    mainProgram = "torus";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
