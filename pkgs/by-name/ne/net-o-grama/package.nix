{
  lib,
  stdenv,
  fetchurl,
  glib,
  ncurses,
  pkg-config,
  SDL,
  SDL_mixer,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "net-o-grama";
  version = "0.3";

  src = fetchurl {
    url = "mirror://sourceforge/net-o-grama/net-o-grama/nog-${finalAttrs.version}/nog_0_3.tar.gz";
    hash = "sha256-TTYFUA2vKsnAzdiJafxTHL7KMjTSD4WHErXuNSO3zfU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    glib
    ncurses
    SDL
    SDL_mixer
  ];

  NIX_CFLAGS_COMPILE = [
    "-std=gnu99"
    "-fcommon"
    "-Wno-error=incompatible-pointer-types"
  ];

  buildPhase = ''
    runHook preBuild

    glib_cflags="$(pkg-config --cflags glib-2.0)"
    glib_libs="$(pkg-config --libs glib-2.0)"
    sdl_cflags="$(pkg-config --cflags sdl)"
    sdl_libs="$(pkg-config --libs sdl)"
    sdl_mixer_cflags="$(pkg-config --cflags SDL_mixer)"
    sdl_mixer_libs="$(pkg-config --libs SDL_mixer)"

    $CC $CPPFLAGS $CFLAGS \
      -o nog_srv \
      src/debug.c src/network.c src/engine.c src/dlb.c src/linked.c src/nog_srv.c \
      $glib_cflags $glib_libs \
      $LDFLAGS

    $CC $CPPFLAGS $CFLAGS \
      -o nog_ncurses \
      src/debug.c src/network.c src/engine.c src/dlb.c src/linked.c src/cli_ncurses.c src/client.c src/sound.c src/nog_ncurses.c \
      $glib_cflags $glib_libs \
      $sdl_cflags $sdl_libs \
      $sdl_mixer_cflags $sdl_mixer_libs \
      -lncurses -lm \
      $LDFLAGS

    $CC $CPPFLAGS $CFLAGS \
      -o nog_ncurses_nosound \
      src/debug.c src/network.c src/engine.c src/dlb.c src/linked.c src/cli_ncurses.c src/client_nosound.c src/nog_ncurses_nosound.c \
      $glib_cflags $glib_libs \
      $sdl_cflags $sdl_libs \
      -lncurses -lm \
      $LDFLAGS

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/bin" "$out/libexec/net-o-grama"

    install -Dm755 nog_srv -t "$out/libexec/net-o-grama"
    install -Dm755 nog_ncurses -t "$out/libexec/net-o-grama"
    install -Dm755 nog_ncurses_nosound -t "$out/libexec/net-o-grama"

    cat > "$out/bin/nog_srv" <<EOF
    #!${stdenv.shell}
    cd "$out/share/net-o-grama"
    exec "$out/libexec/net-o-grama/nog_srv" "\$@"
    EOF
    chmod +x "$out/bin/nog_srv"

    cat > "$out/bin/nog_ncurses" <<EOF
    #!${stdenv.shell}
    cd "$out/share/net-o-grama"
    exec "$out/libexec/net-o-grama/nog_ncurses" "\$@"
    EOF
    chmod +x "$out/bin/nog_ncurses"

    cat > "$out/bin/nog_ncurses_nosound" <<EOF
    #!${stdenv.shell}
    cd "$out/share/net-o-grama"
    exec "$out/libexec/net-o-grama/nog_ncurses_nosound" "\$@"
    EOF
    chmod +x "$out/bin/nog_ncurses_nosound"

    install -Dm644 wordlist.txt -t "$out/share/net-o-grama"
    install -Dm644 audio/*.wav -t "$out/share/net-o-grama/audio"
    install -Dm644 audio/ReadMe -t "$out/share/net-o-grama/audio"

    install -Dm644 AUTHORS ChangeLog NEWS ReadMe -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 License -t "$out/share/licenses/${finalAttrs.pname}"

    runHook postInstall
  '';

  # Interactive ncurses game; no stable non-interactive mode.

  meta = {
    description = "Networked word game with ncurses client and server";
    homepage = "https://sourceforge.net/projects/net-o-grama/";
    license = lib.licenses.gpl2Plus;
    mainProgram = "nog_ncurses";
    maintainers = with lib.maintainers; [ Zaczero ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
