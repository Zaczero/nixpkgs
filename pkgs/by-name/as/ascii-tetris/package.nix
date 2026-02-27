{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ascii-tetris";
  version = "0-unstable-2017-11-20";

  src = fetchFromGitHub {
    owner = "Gregwar";
    repo = "ASCII-Tetris";
    rev = "f983b0488a43bfea9ab1637f31596bbb94a1135e";
    hash = "sha256-heIQQ/T7h9pZi4YvcbGVF1wX/dCiHCRPa2hNF/T/U+U=";
  };

  strictDeps = true;

  buildPhase = ''
    runHook preBuild

    make \
      CC=${stdenv.cc.targetPrefix}cc \
      FLAGS="-I./ -O3 ${lib.optionalString stdenv.hostPlatform.isLinux "-lrt"}"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 Tetris "$out/bin/ascii-tetris"
    install -Dm644 README.md LICENSE -t "$out/share/doc/ascii-tetris"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "ASCII Tetris for the terminal";
    homepage = "https://github.com/Gregwar/ASCII-Tetris";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "ascii-tetris";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
