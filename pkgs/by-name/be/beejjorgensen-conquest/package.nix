{
  lib,
  buildPackages,
  stdenv,
  fetchFromGitHub,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "beejjorgensen-conquest";
  version = "original";

  src = fetchFromGitHub {
    owner = "beejjorgensen";
    repo = "conquest";
    rev = "34bb4a81c6e09aedf32baaca336670432ee3f577";
    hash = "sha256-qmOxvHE79aM1eMTpQpeYu3JRMdYXM2j4MrLB+PZ20wU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    # `make` uses `tput` (from ncurses) at build time.
    buildPackages.ncurses
  ];

  buildInputs = [ ncurses ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "LDFLAGS=-lncurses"
    "LDFLAGS+=-lm"
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    mkdir -p "$TMPDIR/home"
    TERM=xterm HOME="$TMPDIR/home" timeout --kill-after=1s 10s ./conquest >/dev/null 2>&1 || test "$?" -eq 124

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 conquest -t "$out/bin"
    install -Dm644 README.md instructions.txt -t "$out/share/doc/${finalAttrs.pname}"
    cp -a archives "$out/share/doc/${finalAttrs.pname}/archives"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modernized terminal version of the classic strategy game Conquest";
    homepage = "https://github.com/beejjorgensen/conquest";
    # No license file/notice found in the upstream repo snapshot; treat as all-rights-reserved.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "conquest";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
