{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  ncurses,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mangband";
  version = "1.5.3";

  src = fetchurl {
    url = "https://www.mangband.org/download/${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
    hash = "sha256-FbliNk7+mI9EAt0v1OAm0DBXWt3r2UTqFjeqNV98gPs=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  nativeBuildInputs = [
    buildPackages.stdenv.cc
    which
  ];

  # The bundled RSA MD5 implementation defaults to K&R-style empty prototypes.
  # Enable ANSI prototypes instead of patching upstream sources.
  NIX_CFLAGS_COMPILE = [
    "-DPROTOTYPES=1"
    "-fcommon"
  ];

  postPatch = ''
    # The bundled RSA MD5 code assumes ILP32 where `unsigned long` is 32-bit.
    # On LP64 platforms, this breaks the build due to type mismatches with the
    # game's `u32b` type. Adjust the MD5 function prototypes to use `u32b`,
    # keeping the implementation itself unchanged.
    substituteInPlace src/common/md5.c \
      --replace-fail \
        "static void MD5Transform PROTO_LIST ((unsigned long [4], unsigned char [64]));" \
        "static void MD5Transform PROTO_LIST ((u32b [4], unsigned char [64]));" \
      --replace-fail \
        "((unsigned char *, unsigned long *, unsigned int));" \
        "((unsigned char *, u32b *, unsigned int));" \
      --replace-fail \
        "((unsigned long *, unsigned char *, unsigned int));" \
        "((u32b *, unsigned char *, unsigned int));"

    # C23/modern toolchains treat `()` as an empty parameter list in some
    # contexts; make the callback signature explicit.
    substituteInPlace src/client/ui.h \
      --replace-fail "void (*refresh)();" "void (*refresh)(menu_type *menu);"

    # Avoid conflicting prototypes with modern libc headers.
    substituteInPlace src/server/util.c \
      --replace-fail "extern struct passwd *getpwuid();" "" \
      --replace-fail "extern struct passwd *getpwnam();" ""

    substituteInPlace src/server/externs.h \
      --replace-fail "extern void text_out_save();" "extern void text_out_save(player_type *p_ptr);" \
      --replace-fail "extern void text_out_load();" "extern void text_out_load(player_type *p_ptr);"
  '';

  configureFlags = [
    "--disable-win"
    "--disable-osx"
    "--disable-xdg"
    "--with-crb=no"
    "--with-x11=no"
    "--with-sdl=no"
    "--with-sdl2=no"
    "--with-gcu=yes"
    "--datadir=${placeholder "out"}/share/${finalAttrs.pname}"
  ];

  preConfigure = ''
    # Cross-builds can't run malloc/realloc probes; avoid gnulib rpl_* symbols.
    export ac_cv_func_malloc_0_nonnull=yes
    export ac_cv_func_realloc_0_nonnull=yes
  '';

  postInstall = ''
    install -Dm644 README -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 COPYING -t "$out/share/licenses/${finalAttrs.pname}"
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck

    # The program is interactive, but `-h` prints help and exits.
    output="$(./mangband -h 2>&1 || true)"
    grep -Fqi "usage:" <<<"$output"

    runHook postCheck
  '';

  meta = {
    description = "Multiplayer roguelike based on Angband";
    homepage = "https://www.mangband.org/";
    # MAngband license: permits redistribution for educational/research/not-for-profit.
    # That is not a standard FOSS license, so treat as unfree.
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "mangband";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
