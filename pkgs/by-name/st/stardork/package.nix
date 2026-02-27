{
  lib,
  stdenv,
  fetchurl,
  ncurses,
  binutils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stardork";
  version = "0.7";

  src = fetchurl {
    url = "mirror://sourceforge/stardork/stardork-${finalAttrs.version}.tar.gz";
    hash = "sha256-T/MSkb0JGm1htbNMAe0Su20htUljl/1sowwHY1ZaMfU=";
    name = "${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  hardeningDisable = [
    "format"
  ];

  nativeCheckInputs = [
    binutils
  ];

  buildPhase = ''
    runHook preBuild

    $CC $CPPFLAGS $CFLAGS -std=gnu89 -o stardork stardork.c $LDFLAGS -lncurses

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    test -x ./stardork
    ${binutils}/bin/nm -u ./stardork | grep -Fq "initscr"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 stardork -t "$out/bin"
    install -Dm644 README -t "$out/share/doc/${finalAttrs.pname}"

    runHook postInstall
  '';

  meta = {
    description = "Console-based space maze game using ncurses";
    homepage = "http://stardork.sourceforge.net/";
    # Upstream tarball does not include a license file/notice; treat as all-rights-reserved.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
    mainProgram = "stardork";
  };
})
