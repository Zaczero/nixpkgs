{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  ncurses,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ctris";
  version = "0.43";

  src = fetchFromGitHub {
    owner = "0xminik";
    repo = "ctris";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Pz960V2aBFofIBB13WGFUm7oavvFOzv+K/G7+RSyqdU=";
  };

  strictDeps = true;

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [ ncurses ];

  postPatch = ''
    substituteInPlace ctris.h \
      --replace-fail '#define VERSION "v0.42" // version info' '#define VERSION "${finalAttrs.version}" // version info'

    # Drop compile-time date from version output for reproducible builds.
    substituteInPlace ctris.c \
      --replace-fail 'ctris %s, built on %s.' 'ctris %s.' \
      --replace-fail '", VERSION, __DATE__);' '", VERSION);'

    substituteInPlace screen.h \
      --replace-fail 'void put_key();' 'void put_key(int value);'
  '';

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ctris -t "$out/bin"
    installManPage ctris.6.gz
    install -Dm644 AUTHORS COPYING LICENSE README -t "$out/share/doc/ctris"

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  versionCheckProgramArg = "-v";

  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/ctris" -h | grep -Fq "parameter list"
    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Console Tetris clone using ncurses";
    homepage = "https://github.com/0xminik/ctris";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "ctris";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
