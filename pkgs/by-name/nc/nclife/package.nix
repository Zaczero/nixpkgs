{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nclife";
  version = "0-unstable-2016-03-30";

  src = fetchFromGitHub {
    owner = "mikepierce";
    repo = "ncLife";
    rev = "918213154ab281079e29979b4ec6d774179657db";
    hash = "sha256-z5BwF/by17UJF2+ztWTUz/8dxXbrrTi2rndF4ZMgY5Y=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  buildPhase = ''
    runHook preBuild

    $CXX $CPPFLAGS $CXXFLAGS -std=c++11 \
      -o nclife \
      *.cpp \
      $LDFLAGS -lncurses -lrt

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 nclife -t "$out/bin"

    install -Dm644 README.md ChangeLog -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 LICENSE -t "$out/share/licenses/${finalAttrs.pname}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Conway's Game of Life in ncurses";
    homepage = "https://github.com/mikepierce/ncLife";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "nclife";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
