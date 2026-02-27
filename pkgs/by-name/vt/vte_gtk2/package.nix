{
  lib,
  stdenv,
  fetchurl,
  file,
  pkg-config,
  gettext,
  intltool,
  glib,
  gtk2,
  pango,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vte-gtk2";
  version = "0.28.2";

  src = fetchurl {
    url = "mirror://gnome/sources/vte/0.28/vte-${finalAttrs.version}.tar.xz";
    hash = "sha256-hs8LgaoCP6k+1BVlPVHJZ2fyCy1zNMiTyrpx5CZUsK4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    gettext
    intltool
    glib
    file
  ];

  buildInputs = [
    glib
    gtk2
    pango
    ncurses
  ];

  postPatch = ''
    # Upstream libtool macros hardcode `/usr/bin/file`, which doesn't exist in
    # Nix builds. Use `file` from our nativeBuildInputs instead.
    substituteInPlace configure ltmain.sh aclocal.m4 --replace-fail \
      "/usr/bin/file" \
      "${lib.getExe file}"
  '';

  configureFlags = [
    "--with-gtk=2.0"
    "--disable-python"
    "--disable-gtk-doc"
    "--disable-gnome-pty-helper"
  ];
  NIX_CFLAGS_COMPILE = [
    "-Wno-error"
    "-Wno-incompatible-pointer-types"
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck
    output="$(./src/vte --help 2>&1)"
    grep -Fq "Usage:" <<<"$output"
    runHook postCheck
  '';

  postInstall = ''
    install -Dm644 NEWS README AUTHORS doc/readme.txt -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 ChangeLog ChangeLog.pre-git -t $out/share/doc/${finalAttrs.pname}

    install -Dm644 COPYING -t $out/share/licenses/${finalAttrs.pname}
  '';

  meta = {
    description = "Terminal emulator widget for GTK+ 2";
    homepage = "https://wiki.gnome.org/Apps/Terminal/VTE";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
