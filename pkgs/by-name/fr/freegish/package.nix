{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  SDL2,
  openal,
  libvorbis,
  libpng,
  libGL,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "freegish";
  version = "0-unstable-2024-03-23";

  src = fetchFromGitHub {
    owner = "freegish";
    repo = "freegish";
    rev = "f6a92933c9ba584214304b12405a6fd6ab0c3cdf";
    hash = "sha256-UOQoYJWs1U+jcwN0YZ/zDHieSePBhkPlcFDo/w9OjaM=";
  };

  strictDeps = true;

  nativeBuildInputs = [ cmake ];

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      "cmake_minimum_required(VERSION 2.9)" \
      "cmake_minimum_required(VERSION 3.5)"

    substituteInPlace src/config.h --replace-fail "typedef enum {FALSE = 0, TRUE = 1} bool;" "#define FALSE 0
    #define TRUE 1"
  '';

  buildInputs = [
    SDL2
    openal
    libvorbis
    libpng
    libGL
  ];

  postInstall = ''
    install -Dm644 ../License.txt ../README.markdown -t $out/share/doc/freegish/
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Open-source clone of Gish";
    homepage = "https://github.com/freegish/freegish";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "freegish";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
