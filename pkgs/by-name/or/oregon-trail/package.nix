{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "oregon-trail";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "yudonglin";
    repo = "Oregon-Trail";
    rev = "15041a15602b65d275b7898af61e5c98967a2421";
    hash = "sha256-QktWuHJ9G4TnLxBUiY1mIJfaGDwLIb0e2SoABT4Pm/0=";
  };

  strictDeps = true;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  # Fully interactive.

  installPhase = ''
    runHook preInstall

    install -Dm755 "Oregon-Trail[${finalAttrs.version}].py" "$out/share/${finalAttrs.pname}/oregon-trail.py"
    install -Dm644 "$src/README.txt" "$out/share/doc/${finalAttrs.pname}/README.txt"

    makeWrapper "${lib.getExe python3}" "$out/bin/oregon-trail" \
      --add-flags "$out/share/${finalAttrs.pname}/oregon-trail.py"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Educational Oregon Trail-style terminal game (Python)";
    homepage = "https://github.com/yudonglin/Oregon-Trail";
    # No explicit license file/notice in this repository snapshot.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "oregon-trail";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
