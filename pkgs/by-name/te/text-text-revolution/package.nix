{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "text-text-revolution";
  version = "0.11";

  src = fetchurl {
    name = "ttr-${finalAttrs.version}.tar.gz";
    url = "mirror://sourceforge/ttr/ttr/ttr-${finalAttrs.version}/ttr-${finalAttrs.version}.tar.gz";
    hash = "sha256-lihES0qDKIRsfKn8sIMaBWZOMjmEaOZ27Q0VfSiayB0=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  NIX_CFLAGS_COMPILE = [
    "-std=gnu89"
    "-fcommon"
  ];

  # Interactive ncurses program; no stable non-interactive flags (e.g. `--help`
  # currently crashes), so we can't run a meaningful checkPhase here.

  postInstall = ''
    install -Dm644 README -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 COPYING -t $out/share/licenses/${finalAttrs.pname}
  '';

  meta = {
    description = "Dance Dance Revolution clone for character displays";
    homepage = "https://sourceforge.net/projects/ttr/";
    license = lib.licenses.gpl2Only;
    mainProgram = "ttr";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
