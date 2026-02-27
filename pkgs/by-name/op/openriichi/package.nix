{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  vala,
  wrapGAppsHook3,
  nix-update-script,
  glib,
  gtk3,
  libgee,
  glew,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  pango,
  zlib,
  libGL,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openriichi";
  version = "0.2.1.1";

  src = fetchFromGitHub {
    owner = "FluffyStuff";
    repo = "OpenRiichi";
    rev = "cf3f6e53bc3c10547c579bd1f4dda5bea8b3a7d0";
    hash = "sha256-ICifjbAFeBsDJZepcQhCQqgOQnFW6L6i4ufG3sCprxg=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    libgee
    glew
    SDL2
    SDL2_image
    SDL2_mixer
    pango
    zlib
    libGL
  ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-error=int-conversion"
    "-Wno-int-conversion"
  ];

  postInstall = ''
    install -Dm644 "$src/README.md" "$out/share/doc/${finalAttrs.pname}/README.md"
    install -Dm644 "$src/CHANGELOG.md" "$out/share/doc/${finalAttrs.pname}/CHANGELOG.md"

    install -Dm444 "$src/LICENSE" "$out/share/licenses/${finalAttrs.pname}/LICENSE"
    install -Dm444 "$src/Engine/LICENSE" "$out/share/licenses/${finalAttrs.pname}/Engine-LICENSE"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open-source Japanese Mahjong (riichi) client";
    homepage = "https://github.com/FluffyStuff/OpenRiichi";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "OpenRiichi";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
