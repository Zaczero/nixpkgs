{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "monousa";
  version = "2.0";

  src = fetchurl {
    url = "mirror://ibiblioPubLinux/games/multiplayer/monoUSA${finalAttrs.version}.tgz";
    hash = "sha256-qSIm2YxtfWRVDI3gYorAyA6RwbMR2fcxeE0pBewvuMs=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  buildPhase = ''
    runHook preBuild

    $CC \
      -std=gnu89 \
      $NIX_CFLAGS_COMPILE \
      -include string.h \
      -include unistd.h \
      -I${lib.getDev ncurses}/include \
      -o monoUSA2.0x \
      monoUSA2.0.c \
      -lncurses

    runHook postBuild
  '';

  # Fully interactive ncurses UI; no reliable non-interactive self-test mode.

  installPhase = ''
    runHook preInstall

    install -Dm755 monoUSA2.0x "$out/bin/monousa"
    install -Dm644 monoUSArc.data "$out/share/${finalAttrs.pname}/monoUSArc.data"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README -t "$out/share/doc/${finalAttrs.pname}"
  '';

  meta = {
    description = "Networked Monopoly-like board game for terminals using ncurses";
    homepage = "https://ibiblio.org/pub/linux/games/multiplayer/monoUSA2.0.tgz";
    # Upstream tarball does not ship a license file/notice; treat as all rights reserved.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "monousa";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
