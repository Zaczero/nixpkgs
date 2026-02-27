{
  lib,
  stdenvNoCC,
  fetchurl,
  gnused,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sokoban-sed";
  version = "unstable-2023-04-27";

  src = fetchurl {
    url = "http://sed.sourceforge.net/local/games/sokoban.sed";
    hash = "sha256-I/Bi9kBFPWoedhaHG+Gkhb6BuOvHEcZDqTBfUpuD4YE=";
  };

  strictDeps = true;

  nativeBuildInputs = [ gnused ];

  dontUnpack = true;

  doCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  checkPhase = ''
    runHook preCheck

    # Start the game: press enter, pick level 1, then quit.
    timeout 5s sh -c 'printf "\n1\n:q\n" | ${gnused}/bin/sed -nf "$src" >/dev/null'

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/sokoban-sed"

    # The upstream shebang uses /bin/sed, which won't exist in Nix builds.
    substituteInPlace "$out/bin/sokoban-sed" \
      --replace-fail "#!/bin/sed -nf" "#!${gnused}/bin/sed -nf"

    runHook postInstall
  '';

  doInstallCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  installCheckPhase = ''
    runHook preInstallCheck

    # Start the game: press enter, pick level 1, then quit.
    timeout 5s sh -c 'printf "\n1\n:q\n" | "$out/bin/sokoban-sed" >/dev/null'

    runHook postInstallCheck
  '';

  meta = {
    description = "Sokoban clone implemented as a sed script";
    homepage = "http://sed.sourceforge.net/local/games/sokoban.sed.html";
    # No license statement for the script itself is included in the downloaded file.
    license = lib.licenses.unfree;
    mainProgram = "sokoban-sed";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
