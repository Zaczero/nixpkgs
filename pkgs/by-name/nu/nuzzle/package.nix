{
  lib,
  stdenv,
  fetchFromGitHub,
  gnumake,
  installShellFiles,
  nix-update-script,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nuzzle";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "dead-end";
    repo = "nuzzle";
    rev = "626fefa09ec96a7f44319be04f2aaf6d971d813f";
    hash = "sha256-QhiVS8JdQKjfaAyUxMzFKeHW2ff0b+5AyH9oELaM9uE=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gnumake
    installShellFiles
  ];

  buildInputs = [
    ncurses
  ];

  makeFlagsArray = [
    "PREFIX=$(out)"
    "NCURSES_CONFIG=${lib.getDev ncurses}/bin/ncursesw6-config"
    # Avoid build failures due to -Werror on newer toolchains.
    "WARN_FLAGS=-Wall -Wextra -Wpedantic"
  ];

  buildPhase = ''
    runHook preBuild

    make ''${makeFlagsArray[@]} nuzzle ut_test

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck

    make ''${makeFlagsArray[@]} tests

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 nuzzle -t "$out/bin"
    install -Dm644 cfg/*.cfg -t "$out/share/games/nuzzle"
    installManPage man/nuzzle.6

    install -Dm644 README.md changelog -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 LICENSE -t "$out/share/licenses/${finalAttrs.pname}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal-based puzzle game collection using ncurses";
    homepage = "https://github.com/dead-end/nuzzle";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "nuzzle";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
