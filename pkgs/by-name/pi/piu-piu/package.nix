{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "piu-piu";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "vaniacer";
    repo = "piu-piu-SH";
    rev = "c7da41c07a924b5a074d595efbbad2f0271575a3";
    hash = "sha256-lwInRjaASHejyqwXuZLuKGj/vEbipgdHgVhQLX09nsc=";
  };

  strictDeps = true;

  dontConfigure = true;
  dontBuild = true;

  doCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  checkPhase = ''
    runHook preCheck

    ${stdenvNoCC.shellDryRun} ./piu-piu

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 piu-piu -t "$out/bin"

    install -Dm644 "$src/README.md" "$out/share/doc/$pname/README.md"
    install -Dm444 "$src/LICENSE.md" "$out/share/licenses/$pname/LICENSE.md"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Alien invasion shooter game written in pure Bash";
    homepage = "https://github.com/vaniacer/piu-piu-SH";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "piu-piu";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
