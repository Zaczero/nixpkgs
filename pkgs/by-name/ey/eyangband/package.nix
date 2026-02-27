{
  lib,
  stdenv,
  fetchurl,
  unzip,
  ncurses,
  makeWrapper,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eyangband";
  version = "0.5.2";

  src = fetchurl {
    url = "mirror://sourceforge/eyangband/Source/${finalAttrs.version}/eyangband-052-src.zip";
    hash = "sha256-3V1rP9VxnpB4qXtxGUSL0Zv8/pf8oKSTQENWo/dkbXM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];
  buildInputs = [ ncurses ];

  buildPhase = ''
    runHook preBuild

    make -C src -f Makefile.std angband \
      CC=''${CC:-cc} \
      CFLAGS="$CPPFLAGS $CFLAGS -DUSE_GCU -DUSE_NCURSES" \
      LDFLAGS="$LDFLAGS" \
      LIBS="-lncurses" \
      SRCS="z-util.c z-virt.c z-form.c z-rand.c z-term.c variable.c tables.c traps.c util.c cave.c object1.c object2.c object3.c monster1.c monster2.c monster3.c xtra1.c xtra2.c spells1.c spells2.c melee1.c melee2.c save.c files.c cmd-attk.c cmd-book.c cmd-item.c cmd-know.c cmd-misc.c cmd-util.c store.c birth.c squelch.c load.c powers.c info.c wizard.c quest.c effects.c generate.c dungeon.c init1.c init2.c main-gcu.c main.c" \
      OBJS="z-util.o z-virt.o z-form.o z-rand.o z-term.o variable.o tables.o traps.o util.o cave.o object1.o object2.o object3.o monster1.o monster2.o monster3.o xtra1.o xtra2.o spells1.o spells2.o melee1.o melee2.o save.o files.o cmd-attk.o cmd-book.o cmd-item.o cmd-know.o cmd-misc.o cmd-util.o info.o store.o birth.o squelch.o load.o powers.o wizard.o quest.o effects.o generate.o dungeon.o init1.o init2.o main-gcu.o main.o"

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    # Basic non-interactive sanity check (prints usage then exits).
    ./src/angband -h | grep -F "Usage: angband"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 src/angband "$out/bin/eyangband"
    install -d "$out/share/eyangband"
    cp -a lib "$out/share/eyangband/"

    install -Dm644 eychanges5.txt -t "$out/share/doc/eyangband"

    # The game looks for "./lib/" by default; ensure it can find its data.
    wrapProgram "$out/bin/eyangband" \
      --set ANGBAND_PATH "$out/share/eyangband/lib/"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=skip" ];

  };
  meta = {
    description = "Variant of the roguelike dungeon exploration game Angband";
    homepage = "https://eyangband.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    mainProgram = "eyangband";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
