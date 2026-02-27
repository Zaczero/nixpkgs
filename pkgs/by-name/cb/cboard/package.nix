{
  lib,
  stdenv,
  fetchurl,
  ncurses,
  pkg-config,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cboard";
  version = "0.7.5";

  src = fetchurl {
    url = "mirror://sourceforge/c-board/${finalAttrs.version}/cboard-${finalAttrs.version}.tar.bz2";
    hash = "sha256-3XSAOfNTFlPhVzV3zYFHQVJOGxbhbjqEHvUS5RUNpqA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    ncurses
  ];

  postPatch = ''
    substituteInPlace configure --replace-fail \
      'if test "$cross_compiling" = yes; then :' \
      'if test "$cross_compiling" = yes; then ptmx_works=yes; elif false; then :'
  '';

  configureFlags = lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "ac_cv_func_malloc_0_nonnull=yes"
    "ac_cv_func_realloc_0_nonnull=yes"
  ];

  makeFlags = [
    "AR=${stdenv.cc.targetPrefix}ar"
  ];

  NIX_CFLAGS_COMPILE = [
    "-DUNIX98"
    "-fcommon"
  ];

  hardeningDisable = [ "format" ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  postInstall = ''
    install -Dm644 doc/config.example -t "$out/share/doc/cboard"
    install -Dm644 README ChangeLog NEWS THANKS COPYING -t "$out/share/doc/cboard"
  '';

  checkPhase = ''
    runHook preCheck
    ./src/cboard -h >/dev/null
    runHook postCheck
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=skip" ];

  };
  meta = {
    description = "Console PGN browser, editor, and interface to chess engines";
    homepage = "https://sourceforge.net/projects/c-board/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "cboard";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
