{
  lib,
  stdenv,
  fetchzip,
  dds,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lead-solver";
  version = "1.0.2";

  src = fetchzip {
    url = "https://lajollabridge.com/Software/Lead-Solver/leadsolver.zip";
    hash = "sha256-zJZHKTA8yoybtGbjZZaQLYQPOm9wp8Bs7jkpOfKPntM=";
  };

  strictDeps = true;

  buildInputs = [
    dds
  ];

  buildPhase = ''
    runHook preBuild

    $CXX -o leadsolver leadsolver.cpp -ldds

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck

    output="$(./leadsolver 2>&1 || true)"
    grep -Fq "Usage leadsolver" <<<"$output"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 leadsolver -t "$out/bin"

    install -Dm644 Changelog.txt -t "$out/share/doc/lead-solver"

    runHook postInstall
  '';

  meta = {
    description = "Opening lead analysis tool for bridge using the DDS double dummy solver";
    homepage = "https://lajollabridge.com/Software/Lead-Solver/Lead-Solver-About.htm";
    # Upstream states GPLv3 on the homepage, but the source zip does not carry a
    # dedicated license file.
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "leadsolver";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
