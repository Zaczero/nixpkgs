{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  makeWrapper,
  ncurses,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aliens";
  version = "0-unstable-2019-05-20";

  src = fetchFromGitHub {
    owner = "troglobit";
    repo = "aliens";
    rev = "94b5eb2e1fb054b25d6daf5ac0ead3adc3672ee4";
    hash = "sha256-AzH1rZFqEH8sovZZfJykvsEmCedEZWigQFHWHl6/PdE=";
  };

  strictDeps = true;

  buildInputs = [ ncurses ];

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  postPatch = ''
    # Upstream redeclares `getpwuid()` using an old-style prototype, which
    # conflicts with the declaration from <pwd.h> on modern libc.
    substituteInPlace aliens.c \
      --replace-fail "struct passwd *getpwuid(), *p;" "struct passwd *p;" \
      --replace-fail '#define SCOREFILE  "/var/games/aliens.score"' '#define SCOREFILE "aliens.score"'
  '';

  buildPhase = ''
    runHook preBuild

    $CC $CPPFLAGS $CFLAGS -o aliens aliens.c $LDFLAGS -lncurses

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 aliens "$out/libexec/aliens/aliens"
    makeWrapper "$out/libexec/aliens/aliens" "$out/bin/aliens" \
      --run 'stateDir="''${XDG_STATE_HOME:-$HOME/.local/state}/aliens"' \
      --run 'mkdir -p "$stateDir"' \
      --run 'cd "$stateDir"'

    installManPage aliens.6
    install -Dm644 -t "$out/share/doc/aliens" README.md UNLICENSE

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Defend Earth from swarms of alien invaders in a curses game";
    homepage = "https://github.com/troglobit/aliens";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "aliens";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
