{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "minesweeper-sh";
  version = "0-unstable-2013-11-21";

  src = fetchFromGitHub {
    owner = "feherke";
    repo = "Bash-script";
    rev = "711aa548a4c78cf1d3818646d8690227efc7d20f";
    hash = "sha256-pcRKTOuxsDEp72PVMVNjPPtVgYYXaBSMVsOUuZmGK7Y=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
  ];

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  postPatch = ''
    patchShebangs minesweeper/minesweeper.sh
  '';

  dontBuild = true;
  dontConfigure = true;

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck
    ${stdenv.shellDryRun} minesweeper/minesweeper.sh
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 minesweeper/minesweeper.sh "$out/bin/minesweeper.sh"
    installManPage minesweeper/minesweeper.sh.6

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 "$src/minesweeper/CHANGES" -t "$out/share/doc/${finalAttrs.pname}"
  '';

  meta = {
    description = "Text-mode minesweeper game written as a Bash script";
    homepage = "https://github.com/feherke/Bash-script/tree/master/minesweeper";
    # No license file in the upstream repository for this subproject.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "minesweeper.sh";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
