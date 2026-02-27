{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "threes-c";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "harshjv";
    repo = "threes-c";
    rev = "369a0087f965571f971b3261081e766ade4c1e98";
    hash = "sha256-SC3MKd4P6JZepBEQiEj/oiJEvm6efmX4WZrPLmaCgDo=";
  };

  strictDeps = true;

  postPatch = ''
    # Upstream Makefile hardcodes `gcc` for linking, which breaks cross compilation.
    # Keep upstream build structure, but make the linker respect `$CC`.
    substituteInPlace Makefile --replace-fail \
      'gcc -o $@ $^ $(CFLAGS) $(LIBS)' \
      '$(CC) -o $@ $^ $(CFLAGS) $(LIBS)'
  '';

  buildPhase = ''
    runHook preBuild

	    make threes \
	      CC="$CC" \
	      CFLAGS="$NIX_CFLAGS_COMPILE -Iinclude"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 threes -t "$out/bin"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 LICENSE -t $out/share/licenses/${finalAttrs.pname}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal implementation of the Threes game in C";
    homepage = "https://github.com/harshjv/threes-c";
    license = lib.licenses.mit;
    mainProgram = "threes";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
