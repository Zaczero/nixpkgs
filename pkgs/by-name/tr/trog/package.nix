{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "trog";
  version = "0-unstable-2023-10-21";

  src = fetchFromGitHub {
    owner = "JohnAnthony";
    repo = "TROG";
    rev = "b0a88433c2bff947d3d9acfbdcea23e858491110";
    hash = "sha256-UaMBVzvIHNnx2PfqErp13lZ9r10eCZuzdx9DGqWe6FE=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  hardeningDisable = [ "format" ];

  buildPhase = ''
    runHook preBuild

    make trog \
      CXX="${stdenv.cc.targetPrefix}c++" \
      CFLAGS="$NIX_CFLAGS_COMPILE -Iinclude"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 trog -t "$out/bin"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 LICENSE -t $out/share/licenses/${finalAttrs.pname}
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "C++ roguelike dungeon crawler for the terminal (ncurses)";
    homepage = "https://github.com/JohnAnthony/TROG";
    license = lib.licenses.mit;
    mainProgram = "trog";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
