{
  lib,
  stdenv,
  fetchurl,
  gnumake,
  makeWrapper,
  aalib,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pag";
  version = "0.92";

  src = fetchurl {
    url = "http://ftp.lip6.fr/pub/minix/distfiles/local/3.3.0/pag-${finalAttrs.version}.tar.gz";
    hash = "sha256-1fXWjuqqai0aAGse/GzsQIjGMCYM9UsI3F7Hbzem1oY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gnumake
    makeWrapper
  ];

  buildInputs = [
    aalib
    ncurses
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    chmod -R u+w .
    mkdir -p bin

    make -f Makefile.orig compile \
      PREFIX="$out" \
      CC="$CC" \
      CFLAGS="$CFLAGS -std=gnu89" \
      LDFLAGS="$LDFLAGS"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/pag_intro -t "$out/bin"

    install -Dm755 bin/pag -t "$out/libexec"
    makeWrapper "$out/libexec/pag" "$out/bin/pag" \
      --prefix PATH : "$out/bin"

    install -Dm644 doc/* -t "$out/share/doc/${finalAttrs.pname}"

    install -d "$out/share/${finalAttrs.pname}/levels"
    cp -a maps/. "$out/share/${finalAttrs.pname}/levels/"

    runHook postInstall
  '';

  meta = {
    description = "Portable Arcade Game (ncurses-based ASCII platform game)";
    homepage = "https://pkgsrc.se/games/pag";
    # Upstream tarball doesn't ship clear licensing information.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "pag";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
