{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bash,
  coreutils,
  findutils,
  gnugrep,
  gnused,
  gawk,
  makeWrapper,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tossug-arena";
  version = "2018.1";

  src = fetchFromGitHub {
    owner = "tossug";
    repo = "tossug-arena";
    rev = "75054e80d834425a9833294212e6f8f091f339b6";
    hash = "sha256-Qf0L5V7j/XxgNrZrBFPav6Pgml/Cl++zEr592io4DsI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  dontBuild = true;

  doCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  checkPhase = ''
    runHook preCheck

    output="$(${bash}/bin/bash ./tossug-arena 2>&1 || true)"
    grep -Fq "Usage:" <<<"$output"
    grep -Fq "available MATCH" <<<"$output"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/share/tossug-arena"
    cp -a matches players interfaces "$out/share/tossug-arena"

    # Preserve upstream behavior: when invoked as `./tossug-arena`, it uses the
    # current working directory as the data root.
    install -Dm755 tossug-arena "$out/libexec/tossug-arena/tossug-arena"
    patchShebangs "$out/libexec/tossug-arena/tossug-arena"

    makeWrapper "$out/libexec/tossug-arena/tossug-arena" "$out/bin/tossug-arena" \
      --chdir "$out/share/tossug-arena" \
      --prefix PATH : "${
        lib.makeBinPath [
          bash
          coreutils
          findutils
          gnugrep
          gnused
          gawk
        ]
      }"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 LICENSE -t $out/share/licenses/${finalAttrs.pname}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Gamelets arena for building simple board-game agents";
    homepage = "https://github.com/tossug/tossug-arena";
    license = lib.licenses.cc0;
    mainProgram = "tossug-arena";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
