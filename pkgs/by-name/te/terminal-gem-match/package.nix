{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "terminal-gem-match";
  version = "0-unstable-2016-05-07";

  src = fetchFromGitHub {
    owner = "Andrew-Bennett-ProMX";
    repo = "terminal_gem_match";
    rev = "c6ca36aff56f673f01f6790057966378ebc31d2c";
    hash = "sha256-1SxtM002LkSjyIVV5wGzuko0jI0pP4z+mIP/FSxxLis=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  hardeningDisable = [ "format" ];

  buildPhase = ''
    runHook preBuild

    make CC="$CXX -std=c++14" CFLAGS="$NIX_CFLAGS_COMPILE" LFLAGS="-lncurses"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/terminal_gem_match -t "$out/bin"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 LICENSE.md -t $out/share/licenses/${finalAttrs.pname}
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Match-3 game for the terminal using ncurses";
    homepage = "https://github.com/Andrew-Bennett-ProMX/terminal_gem_match";
    license = lib.licenses.gpl3Plus;
    mainProgram = "terminal_gem_match";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
