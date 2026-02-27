{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  lua5_1,
  meson,
  ninja,
  physfs,
  pkg-config,
  python3,
  SDL2,
  SDL2_mixer,
  SDL2_ttf,
  freetype,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "netpanzer";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "netpanzer";
    repo = "netpanzer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wXDyxpldmfc/uxv1HBhT3dLohupJy81E7RmD2FArhHo=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    python3
  ];

  buildInputs = [
    SDL2
    SDL2_mixer
    SDL2_ttf
    freetype
    lua5_1
    physfs
  ];

  mesonFlags = [
    "-Db_sanitize=none"
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck
    export NETPANZER_DATADIR="$(realpath ../data)"
    export NETPANZER_LOCALEDIR="$(realpath po)"
    meson test --print-errorlogs
    runHook postCheck
  '';

  postInstall = ''
    # Meson installs COPYING.txt into share/doc; nixpkgs expects licenses in
    # share/licenses.
    install -d "$out/share/licenses/${finalAttrs.pname}"
    mv "$out/share/doc/netpanzer/COPYING.txt" "$out/share/licenses/${finalAttrs.pname}/COPYING.txt"

    # Skip developer-only docs.
    rm "$out/share/doc/netpanzer/CONTRIBUTING.md"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Online multiplayer tactical warfare game";
    homepage = "https://github.com/netpanzer/netpanzer";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "netpanzer";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
