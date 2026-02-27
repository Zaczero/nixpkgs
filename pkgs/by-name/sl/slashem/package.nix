{
  lib,
  stdenv,
  fetchurl,
  ncurses,
  flex,
  bison,
  coreutils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "slashem";
  version = "0.0.8E0F1";

  src = fetchurl {
    name = "se008e0f1.tar.gz";
    url = "mirror://sourceforge/slashem/slashem-source/${finalAttrs.version}/se008e0f1.tar.gz";
    hash = "sha256-6b02cshmrMWg114kXBkMaJlWMZ8ZLLXSPqkk3XfkJsM=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  nativeBuildInputs = [
    flex
    bison
  ];

  configureFlags = [
    "--prefix=${placeholder "out"}/games"
    "--with-owner=nobody"
    "--with-group=nogroup"
  ];

  hardeningDisable = [
    "format"
  ];

  NIX_CFLAGS_COMPILE = [
    "-std=gnu89"
  ];

  # Like NetHack, Slash'EM builds several generator tools which are run during
  # the build to produce game data.
  enableParallelBuilding = false;

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck
    (cd src; ../util/makedefs -v)
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    make install \
      CHOWN=true \
      CHGRP=true \
      GAMEPERM=0755 \
      EXEPERM=0755 \
      DIRPERM=0755 \
      FILEPERM=0644 \
      VARFILEPERM=0644 \
      VARDIRPERM=0755

    cat > slashem <<EOF
    #!${stdenv.shell}
    set -eu

    export PATH="${lib.makeBinPath [ coreutils ]}:\$PATH"

    userDir="''${XDG_STATE_HOME:-$HOME/.local/state}/slashem"

    if [ ! -d "$userDir" ]; then
      mkdir -p "$userDir"
      cp -r $out/games/slashemdir/* "$userDir/"
      chmod -R u+w "$userDir"
    fi

    RUNDIR="$(mktemp -d)"
    cleanup() { rm -rf "$RUNDIR"; }
    trap cleanup EXIT

    cd "$RUNDIR"
    for i in "$userDir"/*; do
      ln -s "$i" "$(basename "$i")"
    done

    exec $out/games/slashemdir/slashem "\$@"
    EOF
    ${stdenv.shellDryRun} ./slashem

    install -Dm755 ./slashem "$out/bin/slashem"

    runHook postInstall
  '';

  meta = {
    description = "NetHack variant with more content (Slash'EM)";
    homepage = "https://slashem.sourceforge.net/";
    license = lib.licenses.ngpl;
    mainProgram = "slashem";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
