{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scrap";
  version = "1.1";

  src = fetchurl {
    url = "https://web.archive.org/web/20130524032130/http://www.math.leidenuniv.nl/~mommen/scrap/x10drl1_1/scrap.tar.gz";
    hash = "sha256-PWeRW80O6CbOHCmpZIDd+h11Ash/2hBpjLL4OpUi4/s=";
  };

  sourceRoot = ".";

  buildInputs = [
    ncurses
  ];

  strictDeps = true;

  makeFlags = [
    "-f"
    "makefile.linux"
    "CC=${stdenv.cc.targetPrefix}c++"
    "CXX=${stdenv.cc.targetPrefix}c++"
  ];

  preBuild = ''
    export CXXFLAGS+=" -include cstring -fpermissive -Wno-write-strings"
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 scrap -t "$out/bin"
    install -Dm644 readme.txt manual.txt -t "$out/share/doc/${finalAttrs.pname}"

    runHook postInstall
  '';

  meta = {
    description = "Ten-day roguelike about a robot in a hostile world";
    homepage = "https://web.archive.org/web/20130524032130/http://www.math.leidenuniv.nl/~mommen/scrap/";
    # Upstream tarball does not include a license file/notice; treat as all-rights-reserved.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "scrap";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
