{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  installShellFiles,
  makeWrapper,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "csol";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "nielssp";
    repo = "csol";
    rev = "b3bd1938e20d890b5eafe9d620d74621aef1bf80";
    hash = "sha256-6mKJo22xZOs+ilnEXt2cFMMbD34mWJBsuVxNONlwnt4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    installShellFiles
    makeWrapper
  ];
  buildInputs = [ ncurses ];

  hardeningDisable = [ "format" ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck
    ./csol --version >/dev/null
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 csol -t "$out/bin"
    install -Dm644 "$src/csolrc" -t "$out/share/csol"
    cp -a "$src/games" "$src/themes" "$out/share/csol"
    installManPage "$src/doc/csol.6"
    install -Dm644 "$src/CHANGES.md" "$src/README.md" -t "$out/share/doc/csol"

    wrapProgram "$out/bin/csol" \
      --prefix XDG_CONFIG_DIRS : "$out/share"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Curses-based solitaire collection";
    homepage = "https://github.com/nielssp/csol";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "csol";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
