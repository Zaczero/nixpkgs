{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rummy";
  version = "0-unstable-2013-10-26";

  src = fetchFromGitHub {
    owner = "ljc2154";
    repo = "Rummy";
    rev = "1398c3a16bc13a343a48ce9d6691d8a396f7668b";
    hash = "sha256-fpwnU7oxaPOOom5nlCPQVxqX2J0EjcFPadmHTDHcUT4=";
  };

  strictDeps = true;

  buildPhase = ''
    runHook preBuild

    $CXX $CPPFLAGS $CXXFLAGS -o rummy rummy.cpp $LDFLAGS

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 rummy -t "$out/bin"
    install -Dm644 README.md -t "$out/share/doc/${finalAttrs.pname}"

    runHook postInstall
  '';

  # No non-interactive mode.

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Command-line rummy game with a computer opponent";
    homepage = "https://github.com/ljc2154/Rummy";
    # No license file/notice found in the upstream repo snapshot; treat as all-rights-reserved.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "rummy";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
