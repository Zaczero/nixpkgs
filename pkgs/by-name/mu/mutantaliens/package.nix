{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mutantaliens";
  version = "0-unstable-2012-09-16";

  src = fetchFromGitHub {
    owner = "essarrdee";
    repo = "mutantaliens";
    rev = "ea6d5c8bd60960de8a04c49c0984fa04eb3fcdb7";
    hash = "sha256-kPPxG9/L8VyQ810Zv2i783FE9gdwF/8mgfpKtqQU2+o=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  buildPhase = ''
    runHook preBuild

    $CXX $CPPFLAGS $CXXFLAGS -std=c++11 -O3 \
      -o mutantaliens mutantaliens.cpp \
      $LDFLAGS -lncurses

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 mutantaliens -t "$out/bin"
    install -Dm644 README MANUAL CHANGES -t "$out/share/doc/${finalAttrs.pname}"

    runHook postInstall
  '';

  NIX_CFLAGS_COMPILE = [ "-Wno-error=format-security" ];

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Curses roguelike about surviving on an alien planet";
    homepage = "https://github.com/essarrdee/mutantaliens";
    # No explicit license file in the upstream repository (all rights reserved by default).
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "mutantaliens";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
