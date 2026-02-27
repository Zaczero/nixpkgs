{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  SDL2,
  SDL2_mixer,
  libxmp,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zgloom";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "Swizpig";
    repo = "ZGloom";
    rev = "v${finalAttrs.version}";
    hash = "sha256-weXLViv9b2LbeIsokQlHkhlf/xW9Hf3xHAAqCk7jrxQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    SDL2
    SDL2_mixer
    libxmp
  ];

  NIX_CFLAGS_COMPILE = [
    "-fpermissive"
  ];

  buildPhase = ''
    runHook preBuild

    cxxflags="$($PKG_CONFIG --cflags sdl2 SDL2_mixer libxmp)"
    libs="$($PKG_CONFIG --libs sdl2 SDL2_mixer libxmp)"

    $CXX $cxxflags -c *.cpp
    $CXX $LDFLAGS -o ZGloom ./*.o $libs

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 ZGloom -t "$out/libexec"

    install -Dm644 README.md -t "$out/share/doc/${finalAttrs.pname}"

    makeWrapper "$out/libexec/ZGloom" "$out/bin/zgloom" \
      --set-default SDL_AUDIODRIVER pulseaudio

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Re-implementation of the Amiga FPS Gloom (engine only; requires external game data)";
    homepage = "https://github.com/Swizpig/ZGloom";
    # Upstream explicitly states the licensing situation is unclear.
    license = lib.licenses.unfree;
    mainProgram = "zgloom";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
