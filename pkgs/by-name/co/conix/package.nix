{
  lib,
  stdenv,
  fetchFromBitbucket,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "conix";
  version = "0-unstable-2013-03-21";

  src = fetchFromBitbucket {
    owner = "garnold";
    repo = "conix";
    rev = "7a52fa71579c5aa156b466d9030ab431dde5e64a";
    hash = "sha256-AzH1rZFqEH8sovZZfJykvsEmCedEZWigQFHWHl6/PdE=";
  };

  strictDeps = true;

  # Use make's $(...) expansion so it reads the environment-provided variable
  # instead of interpreting `$NIX_CFLAGS_COMPILE` as `$N` + `IX_...`.
  makeFlags = [ "CFLAGS=$(NIX_CFLAGS_COMPILE)" ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck
    ./conix --help >/dev/null
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 conix -t "$out/bin"
    install -Dm644 README -t "$out/share/doc/conix"
    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://bitbucket.org/garnold/conix.git";
    hardcodeZeroVersion = true;
  };

  meta = {
    description = "Console-based Xonix clone";
    homepage = "https://bitbucket.org/garnold/conix/";
    # No license file/notice found in the upstream repo snapshot; treat as all-rights-reserved.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "conix";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
