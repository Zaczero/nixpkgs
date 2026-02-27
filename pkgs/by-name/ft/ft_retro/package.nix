{
  lib,
  stdenv,
  fetchFromGitLab,
  makeWrapper,
  python3,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ft_retro";
  version = "0-unstable-2023-01-11";

  src = fetchFromGitLab {
    owner = "Heagan";
    repo = "ft_retro";
    rev = "0f7cc78ddfeb4ea71db099591dfa013c3d16e2bb";
    hash = "sha256-LqU+2mvgHkPmhTUaREVdmPr6Zx/bAwwBpxB/hivRYJ8=";
  };

  strictDeps = true;

  nativeBuildInputs = [ makeWrapper ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck
    ${python3}/bin/python -m py_compile src/main.py
    mkdir -p "$TMPDIR/home"
    TERM=xterm HOME="$TMPDIR/home" timeout --kill-after=1s 10s ${python3}/bin/python src/main.py >/dev/null 2>&1 || test "$?" -eq 124
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 README.md -t "$out/share/doc/${finalAttrs.pname}"
    install -d "$out/share/${finalAttrs.pname}"
    cp -a src classes features headers models ships *.png *.mp3 "$out/share/${finalAttrs.pname}"
    makeWrapper ${python3}/bin/python $out/bin/ft_retro \
      --set PYTHONPATH "$out/share/${finalAttrs.pname}/src" \
      --add-flags "$out/share/${finalAttrs.pname}/src/main.py"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Space Invaders clone in Python (curses) and C++ (SDL2)";
    homepage = "https://gitlab.com/Heagan/ft_retro";
    # No license file/notice found in the upstream repo snapshot (and it bundles assets); treat as all-rights-reserved.
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "ft_retro";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
