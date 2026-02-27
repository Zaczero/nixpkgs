{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cnibbles";
  version = "2.0.1";

  src = fetchurl {
    url = "mirror://sourceforge/cnibbles/Source/cNibbles%20v${finalAttrs.version}/cNibbles-${finalAttrs.version}.tbz";
    hash = "sha256-opW9dN6IdYCgunxPjtJ8OME3/YtiGKtjfq4BmiZ8jQY=";
  };

  strictDeps = true;

  buildInputs = [ ncurses ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "LDLIBS=-lncurses"
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    output="$(./cNibbles --help 2>&1)"
    grep -Fq "Usage: cNibbles" <<<"$output"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 cNibbles -t "$out/bin"
    install -Dm644 CHANGES LICENSE README -t "$out/share/doc/cnibbles"
    runHook postInstall
  '';

  meta = {
    description = "Curses-based version of the classic Nibbles (Snake) game";
    homepage = "https://sourceforge.net/projects/cnibbles/";
    license = lib.licenses.afl21;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "cNibbles";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
