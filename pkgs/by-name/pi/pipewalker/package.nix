{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  SDL2,
  SDL2_image,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pipewalker";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "artemsen";
    repo = "pipewalker";
    rev = "72c4cfa37c48a60aebcd537061163ccb3eabc806";
    hash = "sha256-8JaqoVnzyLRKexR01nvajt4UtVgVcmQk9S6D2yo6KsU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    SDL2
    SDL2_image
  ];

  mesonFlags = [
    (lib.mesonOption "version" finalAttrs.version)
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  versionCheckProgramArg = "--version";

  postInstall = ''
    install -Dm644 "$src/README.md" "$out/share/doc/$pname/README.md"
    install -Dm444 "$src/LICENSE" "$out/share/licenses/$pname/LICENSE"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Puzzle game where you connect components into a single circuit";
    homepage = "https://github.com/artemsen/pipewalker";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "pipewalker";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
