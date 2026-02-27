{
  lib,
  stdenv,
  fetchFromGitHub,
  gnumake,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "landing-rust";
  version = "0-unstable-2020-08-20";

  src = fetchFromGitHub {
    owner = "sergev";
    repo = "landing-rust";
    rev = "5350816d57ed64c873eb7c6ee589265dc155fcf0";
    hash = "sha256-tlMnEQ0R3kOGvfdP1ppLmKwxmeEdQ9LE7J2vz0s6vCk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gnumake
  ];

  buildPhase = ''
    runHook preBuild

    make \
      CXX="$CXX -std=c++11" \
      CXXFLAGS="$NIX_CFLAGS_COMPILE -O2 -Wall" \
      landing

    runHook postBuild
  '';

  # The bundled Catch test runner does not build on modern glibc due to
  # assumptions about signal stack constants, and the game itself is interactive
  # (stdin/stdout) with no non-interactive smoke-test mode.

  installPhase = ''
    runHook preInstall

    install -Dm755 landing -t "$out/bin"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Interactive lunar lander kata (includes multiple reference implementations)";
    homepage = "https://github.com/sergev/landing-rust";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "landing";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
