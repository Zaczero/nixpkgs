{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  nix-update-script,
  versionCheckHook,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "freecell-ng";
  version = "1.2.6";

  src = fetchFromGitHub {
    owner = "ostrosablin";
    repo = "freecell";
    tag = "freecell-${finalAttrs.version}";
    hash = "sha256-QWW84rxeTs9/Q6r1MiKuMgyhwJIZSxb/Uhs9MAlKsOY=";
  };

  strictDeps = true;

  # Cross-compiling: autoconf can't run the malloc(0)/realloc(0) probes, and
  # falls back to rpl_malloc/rpl_realloc without shipping the replacements.
  configureFlags = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    "ac_cv_func_malloc_0_nonnull=yes"
    "ac_cv_func_realloc_0_nonnull=yes"
  ];

  buildInputs = [ ncurses ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/freecell" --help | grep -Fq "Usage: freecell"
    runHook postInstallCheck
  '';

  postInstall = ''
    install -Dm644 AUTHORS ChangeLog NEWS README README.md -t $out/share/doc/freecell-ng/
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ "--version-regex=^freecell-([0-9]+\\.[0-9]+\\.[0-9]+)$" ];
    };
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
      command = "freecell --version";
      version = finalAttrs.version;
    };
  };

  meta = {
    description = "Console freecell game";
    homepage = "https://github.com/ostrosablin/freecell";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "freecell";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
