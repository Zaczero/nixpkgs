{
  lib,
  stdenv,
  fetchFromGitHub,
  bwbasic,
  makeWrapper,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "basic-highnoon";
  version = "0-unstable-2018-08-14";

  src = fetchFromGitHub {
    owner = "mad4j";
    repo = "basic-highnoon";
    rev = "db5a8fc9059cd7798adb388335b0fb028d4b7eb3";
    hash = "sha256-jZXM2i8tq27mKnxXCzK0k6fKc/NsNU5dMGi16uHp2nQ=";
  };

  strictDeps = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm644 HIGHNOON.BAS HIGHNOON64.BAS -t "$out/share/${finalAttrs.pname}"
    install -Dm644 README.md LICENSE -t "$out/share/doc/${finalAttrs.pname}"
    cp -a original "$out/share/doc/${finalAttrs.pname}/original"

    makeWrapper ${lib.getExe bwbasic} "$out/bin/${finalAttrs.pname}" \
      --add-flags "$out/share/${finalAttrs.pname}/HIGHNOON.BAS"

    runHook postInstall
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  nativeCheckInputs = [
    bwbasic
  ];
  checkPhase = ''
    runHook preCheck

    output="$(timeout 5s ${lib.getExe bwbasic} HIGHNOON.BAS < /dev/null || true)"
    grep -Fq "H I G H  N O O N" <<<"$output"

    runHook postCheck
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Early BASIC text game High Noon";
    homepage = "https://github.com/mad4j/basic-highnoon";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "basic-highnoon";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
