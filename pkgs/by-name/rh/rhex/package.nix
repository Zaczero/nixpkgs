{
  lib,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  rustPlatform,
  ncurses,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rhex";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "dpc";
    repo = "rhex";
    rev = "5168efb6944f5fedf7a52ae7be9c582c70d24924";
    hash = "sha256-CLemOHfeAIZu9pxpl+F0xqD08KtkwkchHAURqLmZf/w=";
  };

  strictDeps = true;

  cargoPatches = [
    ./pin-hex2d-dpcext.patch
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    ncurses
  ];

  cargoHash = "sha256-49wT/Tc4SlX9JRFahq+qYVwFFPcGztyTO9MXtSkh0iQ=";

  # The program is an interactive ncurses game; it does not provide a reliable
  # non-interactive `--version/--help` that we can run in checkPhase here.
  doCheck = false;

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple ASCII terminal hexagonal map roguelike";
    homepage = "https://github.com/dpc/rhex";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "rhex";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
