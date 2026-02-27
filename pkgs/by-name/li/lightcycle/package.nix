{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  python3,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lightcycle";
  version = "0-unstable-2023-07-20";

  src = fetchFromGitHub {
    owner = "gsobell";
    repo = "lightcycle";
    rev = "488971132743d0e67ee0d6b5bbaaaa5b27396266";
    hash = "sha256-tvF/5BUE8T1wOVKgPAn8Bo4gmRdWjUQQ34PoRx7x0mU=";
  };

  strictDeps = true;

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  postPatch = ''
    patchShebangs lightcycle.py
  '';

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ python3 ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  versionCheckProgramArg = "-v";

  installPhase = ''
    runHook preInstall

    install -Dm755 lightcycle.py "$out/bin/lightcycle"
    install -Dm644 LICENSE.md README.md -t "$out/share/doc/${finalAttrs.pname}"

    runHook postInstall
  '';

  meta = {
    description = "Classic Tron lightcycle game for the terminal";
    homepage = "https://github.com/gsobell/lightcycle";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "lightcycle";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
