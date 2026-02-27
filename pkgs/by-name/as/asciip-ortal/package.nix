{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  ncurses,
  yaml-cpp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "asciip-ortal";
  version = "1.3-beta8";

  src = fetchFromGitHub {
    owner = "cymonsgames";
    repo = "ASCIIpOrtal";
    rev = "0d7fb0946f760c2b3cd0a1b55a9179914c1a1cb7";
    hash = "sha256-Ccb6x66StJHKTQtDPEQLKrZvcL7XLcBbvAfvORsIn5w=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
    yaml-cpp
  ];

  postPatch = ''
    # The "nosdl" port defines __NOSDL__, but upstream still includes SDL
    # headers unconditionally in src/main.cpp.
    substituteInPlace src/main.cpp \
      --replace-fail "#include <SDL/SDL.h>" $'#ifndef __NOSDL__\n#include <SDL/SDL.h>\n#endif'

    # Upstream hardcodes /usr/share/asciiportal as the base path for media/maps
    # on Unix. Patch it to the Nix store location where we install the data.
    substituteInPlace src/ap_filemgr.cpp \
      --replace-fail "/usr/share/asciiportal" "$out/share/asciiportal"
  '';

  buildPhase = ''
    runHook preBuild

    makeFlagsArray+=(
      PORT=nosdl
      CXX=${stdenv.cc.targetPrefix}c++
      EXE_NAME=asciip-ortal
      "CXXFLAGS=$NIX_CFLAGS_COMPILE -Wno-error=format-security -O2 -DAP_VERSION=\\\"${finalAttrs.version}\\\" -D__NOSDL__ -D__NOSOUND__"
      "LINKFLAGS=-lyaml-cpp -lncursesw"
    )

    make nosdl "''${makeFlagsArray[@]}"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 asciip-ortal "$out/bin/asciip-ortal"
    install -d "$out/share/asciiportal"
    cp -a maps media "$out/share/asciiportal/"
    install -Dm644 README.md LICENSE CHANGELOG.md map_making_tips.md -t "$out/share/doc/asciip-ortal"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=unstable" ];
  };

  meta = {
    description = "ASCII portal puzzle game (text-only ncurses build)";
    homepage = "https://github.com/cymonsgames/ASCIIpOrtal";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "asciip-ortal";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
