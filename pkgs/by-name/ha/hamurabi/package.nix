{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hamurabi";
  version = "0-unstable-2010-06-29";

  src = fetchFromGitHub {
    owner = "blt";
    repo = "hamurabi";
    rev = "994563d7ab48f661471f3aaddca05f18c3a5fa1b";
    hash = "sha256-5Upgn/xjOx4V+Jc7RjLF2Q6I1nhtiQnECVfOZ7/CFxQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [ autoreconfHook ];

  postInstall = ''
    install -Dm644 AUTHORS ChangeLog COPYING NEWS README README.markdown -t "$out/share/doc/hamurabi"
    install -Dm644 doc/HMRABI -t "$out/share/doc/hamurabi"
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck
    input=$(printf '0\n%.0s' {1..60})
    ./src/hamurabi <<<"$input" | grep -Fq "Try your hand"
    runHook postCheck
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Classic Hamurabi text game in C";
    homepage = "https://github.com/blt/hamurabi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "hamurabi";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
