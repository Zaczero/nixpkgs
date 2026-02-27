{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hunt-ng";
  version = "1.0";

  src = fetchurl {
    url = "http://mbays.sdf.org/hunt-ng/src/hunt-ng-${finalAttrs.version}.tar.gz";
    hash = "sha256-bzpn+BAaj9PXwIcSQPxc00Qay0luxzibf0ntye19Yns=";
  };

  strictDeps = true;

  buildInputs = [ ncurses ];

  hardeningDisable = [ "format" ];

  configureFlags = [
    # Autoconf's `AC_CHECK_FUNC(select)` test conflicts with the system
    # declaration of `select(2)` and fails to compile on modern toolchains.
    "ac_cv_func_select=yes"
    "ac_cv_func_malloc_0_nonnull=yes"
    "ac_cv_func_realloc_0_nonnull=yes"
  ];

  NIX_CFLAGS_COMPILE = [
    "-std=gnu89"
    "-Wno-implicit-function-declaration"
    "-Wno-error=implicit-function-declaration"
    "-Wno-error=unused-result"
    "-Wno-unused-result"
    "-include"
    "sys/types.h"
    "-include"
    "sys/select.h"
  ];

  makeFlags = [
    "AR=${stdenv.cc.targetPrefix}ar"
    "RANLIB=${stdenv.cc.targetPrefix}ranlib"
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    # `-h` requires an argument; it prints usage and exits without initializing curses.
    output="$(./hunt/hunt-ng -h 2>&1 || true)"
    grep -Fq "usage:" <<<"$output"

    runHook postCheck
  '';

  postInstall = ''
    install -Dm644 AUTHORS ChangeLog COPYING NEWS README README.ng README.protocol -t $out/share/doc/hunt-ng
  '';

  meta = {
    description = "Multiplayer maze game based on the classic hunt";
    homepage = "http://mbays.sdf.org/hunt-ng/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "hunt-ng";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
