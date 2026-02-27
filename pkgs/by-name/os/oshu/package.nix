{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  pkg-config,
  cairo,
  ffmpeg_4,
  pango,
  SDL2,
  SDL2_image,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "oshu";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "fmang";
    repo = "oshu";
    rev = "32db0236c1b44e27b4d5bc554c101ea67055f50b";
    hash = "sha256-/0f9a5Wrng/4v50oXOfXkUdOF+aPanOQpvQbxmxEqbw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cairo
    ffmpeg_4
    pango
    SDL2
    SDL2_image
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  preCheck = ''
    export SDL_AUDIODRIVER=dummy
    export SDL_VIDEODRIVER=dummy
  '';

  checkPhase = ''
    runHook preCheck

    cmake --build . --target check

    runHook postCheck
  '';

  postInstall = ''
    install -Dm644 "$src/README.md" "$out/share/doc/${finalAttrs.pname}/README.md"
    install -Dm644 "$src/CHANGELOG.md" "$out/share/doc/${finalAttrs.pname}/CHANGELOG.md"

    install -Dm444 "$src/COPYING" "$out/share/licenses/${finalAttrs.pname}/COPYING"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Minimal osu! client for Linux";
    homepage = "https://github.com/fmang/oshu";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "oshu";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux;
  };
})
