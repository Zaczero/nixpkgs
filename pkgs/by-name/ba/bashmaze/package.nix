{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bash,
  coreutils,
  gawk,
  makeWrapper,
  ncurses,
  util-linux,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bashmaze";
  version = "0-unstable-2014-03-01";

  src = fetchFromGitHub {
    owner = "phoemur";
    repo = "bashmaze";
    rev = "eaa8007f6e9b6167e54ec8f64dc70572e88c15f2";
    hash = "sha256-mOjvTVjzACqzxLoPUqoOgnF445AWpu2qfyIvF4xDRgw=";
  };

  strictDeps = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  doCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  checkPhase = ''
    runHook preCheck

    ${stdenvNoCC.shellDryRun} bashmaze.sh

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 bashmaze.sh "$out/share/${finalAttrs.pname}/bashmaze.sh"

    makeWrapper ${bash}/bin/bash "$out/bin/bashmaze" \
      --add-flags "$out/share/${finalAttrs.pname}/bashmaze.sh" \
      --prefix PATH : "${
        lib.makeBinPath [
          coreutils
          gawk
          ncurses
          util-linux
        ]
      }"

    install -Dm644 README.md -t "$out/share/doc/${finalAttrs.pname}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Maze game written in bash";
    homepage = "https://github.com/phoemur/bashmaze";
    license = lib.licenses.unfree;
    mainProgram = "bashmaze";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
