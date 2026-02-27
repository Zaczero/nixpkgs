{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tictac4";
  version = "1.0";

  src = fetchurl {
    url = "mirror://ibiblioPubLinux/games/strategy/tictac4-${finalAttrs.version}.tar.gz";
    hash = "sha256-lpAH56YHe+Tn7vETE0j99FCdtOqfJvOoqlZBTA6zAnw=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CFLAGS="
    "LIBS=-lncurses"
    "LIBS+=-ltinfo"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 tictac4 -t "$out/bin"
    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 COPYING -t $out/share/licenses/${finalAttrs.pname}
  '';

  meta = {
    description = "TicTac2 variant played on a 4x4 field";
    homepage = "https://www.ibiblio.org/pub/linux/games/strategy/";
    license = lib.licenses.gpl2Plus;
    mainProgram = "tictac4";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
