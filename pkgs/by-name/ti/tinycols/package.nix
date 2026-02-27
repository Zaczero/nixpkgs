{
  lib,
  bash,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tinycols";
  version = "0.8.5";

  src = fetchFromGitHub {
    owner = "zedr";
    repo = "tinycols";
    rev = "refs/tags/${finalAttrs.version}";
    hash = "sha256-i9clsJNAAFff8ven+XSHgNV8j+gYSZ4upNVUgJWaSl0=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  nativeBuildInputs = [
    bash
    installShellFiles
  ];

  buildPhase = ''
    runHook preBuild

    make build/tinycols \
      CC="${stdenv.cc.targetPrefix}cc" \
      CFLAGS="$NIX_CFLAGS_COMPILE -Iinclude" \
      SHELL="${bash}/bin/bash"

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    make tests \
      CC="${stdenv.cc.targetPrefix}cc" \
      CFLAGS="$NIX_CFLAGS_COMPILE -Iinclude" \
      DBG_CFLAGS="" \
      SHELL="${bash}/bin/bash"

    ./build/test_tinycols
    ./build/test_queue

    helpOutput="$(./build/tinycols -h 2>&1 || true)"
    grep -Fq "Usage:" <<<"$helpOutput"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 build/tinycols -t "$out/bin"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 LICENSE -t $out/share/licenses/${finalAttrs.pname}
    installManPage doc/man/tinycols.6
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Jewels matching game for the Unix terminal";
    homepage = "https://github.com/zedr/tinycols";
    license = lib.licenses.mit;
    mainProgram = "tinycols";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
