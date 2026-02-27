{
  lib,
  buildPackages,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  zlib,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "watercloset";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "stephenjsweeney";
    repo = "waterCloset";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Xbut+WHC7nM08J5nwjhh2GfvpZo0bOc3NihRa1bm3Ps=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    buildPackages.pkg-config
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    zlib
  ];

  postPatch = ''
    pkgConfig="${lib.getExe buildPackages.pkg-config}"

    substituteInPlace makefile \
      --replace-fail '`sdl2-config --cflags`' "\$(shell $pkgConfig --cflags sdl2)" \
      --replace-fail '`sdl2-config --libs` -lSDL2_mixer -lSDL2_image -lSDL2_ttf -lm' "\$(shell $pkgConfig --libs sdl2 SDL2_image SDL2_mixer SDL2_ttf) -lm"

    substituteInPlace makefile \
      --replace-fail "-Werror " "" \
      --replace-fail "-Werror=maybe-uninitialized " "" \
      --replace-fail "-lefence" ""
  '';

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "DATA_DIR=${placeholder "out"}/share/watercloset"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 waterCloset -t "$out/bin"
    install -Dm755 mapEditor -t "$out/bin"

    install -Dm644 README.md -t "$out/share/doc/${finalAttrs.pname}"

    install -Dm644 LICENSE legalcode.txt -t "$out/share/licenses/${finalAttrs.pname}"
    install -d "$out/share/watercloset"
    cp -a data gfx music sound fonts "$out/share/watercloset"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Puzzle platform game using SDL2 (includes map editor)";
    homepage = "https://github.com/stephenjsweeney/waterCloset";
    # Mixed licensing: code is GPLv3, but game assets are CC BY-NC-SA (non-commercial).
    # Some bundled assets are additionally CC-BY / CC0.
    license = with lib.licenses; [
      gpl3Only
      cc-by-nc-sa-40
      cc-by-40
      cc0
    ];
    mainProgram = "waterCloset";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
