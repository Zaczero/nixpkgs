{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  gettext,
  pango,
  nix-update-script,
  python3,
  binutils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "starfighter";
  version = "2.4.0-1";

  src = fetchFromGitHub {
    owner = "pr-starfighter";
    repo = "starfighter";
    rev = "958574490d96d7a58cc10a70d354d0b09401767b";
    hash = "sha256-lluZ7f/GgAVMcGNhjtnPDVHrOr6TfZOkkg3+eNeHaaM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    gettext
    python3
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    gettext
    pango
  ];

  nativeCheckInputs = [
    binutils
  ];

  preBuild = ''
    (cd locale && python3 build.py)
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    test -x "$out/bin/starfighter"
    stringsOut="$(${binutils}/bin/strings "$out/bin/starfighter")"
    printf '%s\n' "$stringsOut" | grep -F "Project: Starfighter" | head -n 3
    grep -Fq "Project: Starfighter" <<<"$stringsOut"
    grep -Fq "Project: Starfighter %s" <<<"$stringsOut"
    grep -Fq "${finalAttrs.version}" <<<"$stringsOut"

    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "2D space shooter game (Project: Starfighter)";
    homepage = "https://pr-starfighter.github.io/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
    mainProgram = "starfighter";
  };
})
