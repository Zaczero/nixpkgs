{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  python3,
  versionCheckHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dango";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "gsobell";
    repo = "dango";
    rev = "18d2f72be930cdff5f6d739d976da452c12b56a2";
    hash = "sha256-8XOZoagZWAtvGvC0OptLWsOREadzVyG8/vNbWQeJvvo=";
  };

  strictDeps = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  versionCheckProgramArg = "-v";

  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/dango" -h | grep -Fq "a goban for your terminal"
    runHook postInstallCheck
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/share/dango"
    cp -a . "$out/share/dango/"

    makeWrapper ${lib.getExe python3} "$out/bin/dango" \
      --add-flags "$out/share/dango/dango.py" \
      --set PYTHONPATH "$out/share/dango"

    install -Dm644 README.md LICENSE.md -t "$out/share/doc/dango"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Go board for the terminal (ncurses UI)";
    homepage = "https://github.com/gsobell/dango";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "dango";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
