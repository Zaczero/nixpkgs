{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mastermind-nc";
  version = "1.0";

  src = fetchurl {
    url = "mirror://sourceforge/mastermind-nc/mastermind-nc/mastermin-nc-${finalAttrs.version}/${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
    hash = "sha256-kZC3kDv7jF/Pvwyc0oCdBY/6JKG15s5n1HibB+DetBg=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  NIX_CFLAGS_COMPILE = [
    "-fcommon"
    "-include"
    "stdlib.h"
  ];

  buildPhase = ''
    runHook preBuild

    $CC \
      $CPPFLAGS \
      $CFLAGS \
      -Iinclude \
      -o src/mastermind-nc \
      src/*.c \
      -lncurses \
      $LDFLAGS

    runHook postBuild
  '';

  # Fully interactive ncurses UI; no non-interactive self-test mode.

  installPhase = ''
    runHook preInstall

    install -Dm755 src/mastermind-nc -t "$out/libexec"
    install -Dm644 etc/*.txt -t "$out/share/${finalAttrs.pname}"
    install -Dm644 README -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 LICENCE -t "$out/share/licenses/${finalAttrs.pname}"

    makeWrapper "$out/libexec/mastermind-nc" "$out/bin/mastermind-nc" \
      --run 'stateDir="''${XDG_STATE_HOME:-$HOME/.local/state}/mastermind-nc"' \
      --run 'mkdir -p "$stateDir"' \
      --run 'for f in scores.txt informations.txt settings.txt; do if [ ! -f "$stateDir/$f" ]; then cp "$out/share/${finalAttrs.pname}/$f" "$stateDir/$f"; fi; done' \
      --run 'cd "$stateDir"'

    runHook postInstall
  '';

  meta = {
    description = "Text-mode mastermind game using ncurses";
    homepage = "https://sourceforge.net/projects/mastermind-nc/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "mastermind-nc";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
