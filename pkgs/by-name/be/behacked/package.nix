{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "behacked";
  version = "0-unstable-2018-01-04";

  src = fetchFromGitHub {
    owner = "Pentachoron-Labs";
    repo = "Behacked";
    rev = "b9400899286811522a7b8d40df703872e262e731";
    hash = "sha256-U6Io4Nyj2lFfVtBpJqbJ9WrCObVfAYj1F8WH7py+C/I=";
  };

  strictDeps = true;

  buildInputs = [ ncurses ];

  buildPhase = ''
    runHook preBuild

    $CC -o behacked behacked.c -lncurses

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  nativeCheckInputs = [ ];
  checkPhase = ''
    runHook preCheck

    TERM=xterm timeout 10s sh -c 'printf q | ./behacked'

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 behacked -t "$out/bin"
    install -Dm644 README -t "$out/share/doc/${finalAttrs.pname}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Bejeweled-like game for the terminal (ncurses)";
    homepage = "https://github.com/Pentachoron-Labs/Behacked";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "behacked";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
