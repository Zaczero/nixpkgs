{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ascii-snake";
  version = "0-unstable-2016-03-23";

  src = fetchFromGitHub {
    owner = "cyphar";
    repo = "ascii-snake";
    rev = "3107faaac71ada7091135c0beb6c98fb033de487";
    hash = "sha256-rxal+SdR5QuLJC4O0dRFAuUGFG424b3a1HkaGDtvya8=";
  };

  strictDeps = true;

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "WARN=-ansi -Wall -Wextra"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 snake "$out/bin/ascii-snake"
    install -Dm644 README.md COPYING -t "$out/share/doc/ascii-snake"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "ASCII remake of the classic Nokia Snake game";
    homepage = "https://github.com/cyphar/ascii-snake";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "ascii-snake";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
