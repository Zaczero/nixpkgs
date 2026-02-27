{
  lib,
  stdenv,
  fetchurl,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chimaera";
  version = "C1.001A";

  src = fetchurl {
    url = "https://www.mipmip.org/chimaera/chimaera.tgz";
    hash = "sha256-8VtwyICKuBS3Sz/+/WgsExECny+IicmVrAHMxLHJ268=";
  };

  strictDeps = true;

  sourceRoot = "chimaera";

  buildPhase = ''
    runHook preBuild
    $CC $CPPFLAGS $CFLAGS -o chimaera chimaera.c $LDFLAGS -lm
    runHook postBuild
  '';

  # Interactive text adventure; it crashes when run without a tty, so a
  # non-interactive smoke test is not reliable.

  installPhase = ''
    runHook preInstall
    install -Dm755 chimaera -t "$out/bin"
    install -Dm644 chimaera.html README.txt -t "$out/share/doc/chimaera"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=skip" ];

  };
  meta = {
    description = "Text adventure game in the Chimaera series";
    homepage = "https://www.mipmip.org/chimaera/chimaera.html";
    # Upstream tarball does not ship a license file/notice; treat as all-rights-reserved.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "chimaera";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
