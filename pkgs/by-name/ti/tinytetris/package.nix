{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tinytetris";
  version = "0-unstable-2021-10-25";

  src = fetchFromGitHub {
    owner = "taylorconor";
    repo = "tinytetris";
    rev = "38d4cc33cd31fc30ac4599df793164b3ff3c3327";
    hash = "sha256-3f6RFGJ4poB6B8P8X3uFCvC2KqnuuX3l7ZQ0ikgRAQM=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  buildPhase = ''
    runHook preBuild

    make tinytetris \
      CXX="${stdenv.cc.targetPrefix}c++" \
      CXXFLAGS="$NIX_CFLAGS_COMPILE" \
      LDFLAGS="-lncurses"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 tinytetris -t "$out/bin"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 LICENSE -t $out/share/licenses/${finalAttrs.pname}
    install -Dm644 tinytetris-commented.cpp -t $out/share/doc/${finalAttrs.pname}
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "80x23 Tetris clone for the terminal";
    homepage = "https://github.com/taylorconor/tinytetris";
    license = lib.licenses.gpl3Plus;
    mainProgram = "tinytetris";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
