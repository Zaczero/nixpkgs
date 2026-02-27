{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  freetype,
  libarchive,
  lua5_3,
  nix-update-script,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  xorg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "meandmyshadow";
  version = "0.5a";

  src = fetchFromGitHub {
    owner = "acmepjz";
    repo = "meandmyshadow";
    rev = "28392b7a770c12e3ac1dd6cdfc85b0a66b6a300b";
    hash = "sha256-YIszFi1I66h4Db1GYOqApYOYzt88V6q68NOCNP8NzVo=";
  };

  strictDeps = true;

  passthru.updateScript = nix-update-script { };

  postPatch = ''
    substituteInPlace src/MusicManager.h \
      --replace-fail "typedef struct _Mix_Music Mix_Music;" "typedef struct Mix_Music Mix_Music;"
  '';

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  buildInputs = [
    curl
    freetype
    libarchive
    lua5_3
    SDL2
    SDL2_image
    SDL2_mixer
    xorg.libX11
  ];

  # SDL2 game: requires a graphical environment and user input, so we can’t
  # reliably exercise it in the non-interactive nix build sandbox.

  postInstall = ''
    docDir="$out/share/doc/${finalAttrs.pname}"
    install -Dm644 "$src/README.md" "$src/ChangeLog" "$src/AUTHORS" -t "$docDir"
    install -Dm644 "$src/docs/"*.md -t "$docDir"
    install -Dm644 "$src/COPYING" -t "$out/share/licenses/${finalAttrs.pname}"
    mv "$out/share/${finalAttrs.pname}/AUTHORS" "$docDir/"
  '';

  meta = {
    description = "Free puzzle/platform game where you cooperate with your recorded shadow";
    homepage = "https://acmepjz.github.io/meandmyshadow/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "meandmyshadow";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
