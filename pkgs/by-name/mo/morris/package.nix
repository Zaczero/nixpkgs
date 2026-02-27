{
  lib,
  stdenv,
  fetchurl,
  boost,
  gettext,
  intltool,
  pkg-config,
  wrapGAppsHook3,
  glib,
  gtk2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "morris";
  version = "0.3";

  src = fetchurl {
    url = "http://nine-mens-morris.net/data/morris-${finalAttrs.version}.tar.bz2";
    hash = "sha256-f1kOpYB1oXOAKqwb1ya0jfJA5vqxA+v8MjEZ1zPPutM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    intltool
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    boost.dev
    glib
    gtk2
  ];

  configureFlags = [
    "--with-boost=${boost.dev}"

    # Autoconf's malloc/realloc replacement logic (rpl_malloc/rpl_realloc)
    # doesn't work reliably under cross-compilation and breaks with modern
    # libstdc++ headers (e.g. <cstdlib>).
    "ac_cv_func_malloc_0_nonnull=yes"
    "ac_cv_func_realloc_0_nonnull=yes"
  ];

  postConfigure = ''
    # Upstream gettext install uses an unsubstituted @DATADIRNAME@ placeholder,
    # which otherwise installs translations under $out/@DATADIRNAME@/locale.
    #
    # Configure generates these files, so patch them here (no conditional logic).
    substituteInPlace po/Makefile --replace-fail "@DATADIRNAME@" "share"
    substituteInPlace po/Makefile.in --replace-fail "@DATADIRNAME@" "share"
  '';

  postInstall = ''
    # Preserve upstream docs for historical reference.
    install -Dm644 README AUTHORS ChangeLog NEWS -t "$out/share/doc/${finalAttrs.pname}"

    # Keep license material in the canonical nixpkgs location.
    install -Dm644 COPYING -t "$out/share/licenses/${finalAttrs.pname}"
  '';

  enableParallelBuilding = true;

  # GUI program (GTK) without a stable non-interactive test mode.

  meta = {
    description = "Nine Men's Morris game (GTK)";
    homepage = "https://nine-mens-morris.net/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "morris";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
