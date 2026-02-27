{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "znake";
  version = "1.18";

  src = fetchurl {
    url = "mirror://sourceforge/znake-ulven/znake-${finalAttrs.version}/znake-${finalAttrs.version}.tar.gz";
    hash = "sha256-XgFzn8R7vBwtz13169Iu3UZxGZf9XH92Cvm4Bldyr1w=";
    name = "znake-${finalAttrs.version}.tar.gz";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  NIX_CFLAGS_COMPILE = [
    "-fcommon"
  ];

  makeFlags = [
    "-C"
    "src"
    "CC=${stdenv.cc.targetPrefix}cc"
    "CFLAGS=-Wall"
    "CFLAGS+=-lncurses"
    "CFLAGS+=-ltinfo"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 src/znake -t "$out/bin"
    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 ChangeLog -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 COPYING -t $out/share/licenses/${finalAttrs.pname}
  '';

  meta = {
    description = "Snake game for terminal using ncurses";
    homepage = "https://sourceforge.net/projects/znake-ulven/";
    license = lib.licenses.gpl3Plus;
    mainProgram = "znake";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
