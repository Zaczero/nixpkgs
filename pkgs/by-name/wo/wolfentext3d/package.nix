{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  ruby,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "wolfentext3d";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "AtomicPair";
    repo = "wolfentext3d";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-4ZJbzDMuj8nGYqsD97p0B4q3J+Lm12rE8f//Mr2vbKk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 wolfentext.rb -t "$out/share/wolfentext3d"

    install -Dm644 README.md preview.gif -t "$out/share/doc/${finalAttrs.pname}"

    makeWrapper ${lib.getExe ruby} "$out/bin/wolfentext3d" \
      --add-flags "$out/share/wolfentext3d/wolfentext.rb"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Wolfenstein-like ASCII raycaster for the terminal";
    homepage = "https://github.com/AtomicPair/wolfentext3d";
    license = lib.licenses.unlicense;
    mainProgram = "wolfentext3d";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
