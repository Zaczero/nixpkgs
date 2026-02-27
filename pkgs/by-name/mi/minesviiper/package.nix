{
  lib,
  stdenv,
  fetchgit,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "minesviiper";
  version = "0-unstable-2023-10-27";

  src = fetchgit {
    url = "https://git.gir.st/minesVIiper.git";
    rev = "f39a17cdae0c4c5986f8b3f12146910300727b63";
    hash = "sha256-AzH1rZFqEH8sovZZfJykvsEmCedEZWigQFHWHl6/PdE=";
  };

  strictDeps = true;

  passthru.updateScript = unstableGitUpdater {
    url = "https://git.gir.st/minesVIiper.git";
    hardcodeZeroVersion = true;
  };

  buildPhase = ''
    runHook preBuild

    $CC \
      $NIX_CFLAGS_COMPILE \
      -Wall -Wextra -pedantic \
      -o mines \
      mines.c

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck

    output="$(./mines -h 2>&1 || true)"
    grep -Fq "OPTIONS:" <<<"$output"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 mines "$out/bin/${finalAttrs.pname}"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 "$src/README.md" -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 "$src/LICENSE" -t "$out/share/licenses/${finalAttrs.pname}"
  '';

  meta = {
    description = "Minesweeper clone for terminal emulators with vi-style keybindings";
    homepage = "https://gir.st/mines.htm";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "minesviiper";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
