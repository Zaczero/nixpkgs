{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  zlib,
  SDL2,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xjump-sdl";
  version = "3.0.4";

  src = fetchFromGitHub {
    owner = "hugomg";
    repo = "xjump-sdl";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-PiUFfV/fKe79ZYitYbUChEkBO6bsW5XXHIl9gBWhTNU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    SDL2
    zlib
  ];

  # This is a custom (non-autoconf) configure script and it does not understand
  # the standard `--build/--host` flags that stdenv passes for cross builds.
  configurePlatforms = [ ];

  postPatch = ''
    # The upstream `configure` script supports overriding `PKG_CONFIG`, but it
    # only probes `pkg-config` by name. Make it honor `$PKG_CONFIG` so cross
    # builds use the correct wrapper.
    substituteInPlace configure \
      --replace-fail \
        'command -v pkg-config >/dev/null && pkg-config sdl2 --exists' \
        'command -v ''${PKG_CONFIG:-pkg-config} >/dev/null && ''${PKG_CONFIG:-pkg-config} sdl2 --exists' \
      --replace-fail \
        'config="pkg-config sdl2"' \
        'config="''${PKG_CONFIG:-pkg-config} sdl2"'
  '';

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 LICENSE.txt data/LICENSE.md -t $out/share/licenses/${finalAttrs.pname}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Jumping platform game with SDL2";
    homepage = "https://github.com/hugomg/xjump-sdl";
    license = lib.licenses.gpl3Plus;
    mainProgram = "xjump";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
