{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  ncurses,
  libunistring,
  versionCheckHook,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "terminal-pong";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "kumaran-14";
    repo = "terminal-pong";
    rev = finalAttrs.version;
    hash = "sha256-MHGENT62r/2PrQwX9FTow3AYiK//bb29tah+sZKm5TQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    ncurses
    libunistring
  ];

  hardeningDisable = [ "format" ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  versionCheckProgramArg = "--version";

  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/pong" --help | grep -Fq "Usage: pong"
    runHook postInstallCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 pong -t "$out/bin"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 ${finalAttrs.src}/README.md -t $out/share/doc/${finalAttrs.pname}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Ping-pong game played in the terminal";
    homepage = "https://github.com/kumaran-14/terminal-pong";
    # No license file/notice found in the upstream repo snapshot; treat as all-rights-reserved.
    license = lib.licenses.unfree;
    mainProgram = "pong";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
