{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bash,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bash-dungeon";
  version = "0-unstable-2024-07-25";

  src = fetchFromGitHub {
    owner = "wolandark";
    repo = "bash-dungeon";
    rev = "fedd0edfc477e91e909d034714d83adaedd6ca0b";
    hash = "sha256-nVNfYfMcvgSG1oJTeEs07Yf3gptl1A1gcv8OyCZWT8w=";
  };

  strictDeps = true;

  installPhase = ''
    runHook preInstall

    install -d "$out/share/${finalAttrs.pname}"
    cp -a Enter "$out/share/${finalAttrs.pname}/"

    cat > "$out/share/${finalAttrs.pname}/bashrc" <<EOF
    cd "$out/share/${finalAttrs.pname}/Enter"

    if [ -f parchment ]; then
      cat parchment
    fi
    EOF

    install -d "$out/bin"
    cat > "$out/bin/bash-dungeon" <<EOF
    #!${bash}/bin/bash
    set -euo pipefail
    exec "${bash}/bin/bash" --noprofile --norc --rcfile "$out/share/${finalAttrs.pname}/bashrc"
    EOF
    chmod +x "$out/bin/bash-dungeon"

    install -Dm644 README.md LICENSE -t "$out/share/doc/${finalAttrs.pname}"

    runHook postInstall
  '';

  doInstallCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  installCheckPhase = ''
    runHook preInstallCheck

    ${stdenvNoCC.shellDryRun} "$out/bin/bash-dungeon"
    ${stdenvNoCC.shellDryRun} "$out/share/bash-dungeon/bashrc"

    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Filesystem-based dungeon crawler game for learning the shell";
    homepage = "https://github.com/wolandark/bash-dungeon";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "bash-dungeon";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
