{
  lib,
  stdenv,
  fetchgit,
  gnused,
  makeWrapper,
  glibcLocales,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sedchess";
  version = "0-unstable-2013-08-28";

  src = fetchgit {
    url = "https://github.com/bolknote/SedChess";
    rev = "b6923adc627c4543bd3d8d52f68452034f644640";
    hash = "sha256-IJoYZoFvi7zaGSn5jDewYt7ZoXdO5ftMvUIYzuifWEw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  nativeCheckInputs = lib.optionals (stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    glibcLocales
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck
    printf "\nq\n" | env \
      LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive \
      LC_ALL=en_US.UTF-8 \
      ${gnused}/bin/sed -f chess.sed >/dev/null
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 chess.sed -t "$out/share/sedchess"
    makeWrapper ${gnused}/bin/sed "$out/bin/sedchess" \
      --add-flags "-f $out/share/sedchess/chess.sed"
    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Chess game implemented as a sed script";
    homepage = "https://github.com/bolknote/SedChess";
    # No license file/notice found in the upstream repo snapshot; treat as all-rights-reserved.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "sedchess";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
