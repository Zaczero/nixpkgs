{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "proxima5";
  version = "0-unstable-2023-03-22";

  src = fetchFromGitHub {
    owner = "gdamore";
    repo = "proxima5";
    rev = "4d7b71b434d1d366b32975f400f49be5f938e3be";
    hash = "sha256-72BLfjXYbqZ0y3RWF1+cb5SPf4eyLHWLXTlV4tmS/xg=";
  };

  strictDeps = true;

  vendorHash = "sha256-n7v97CV8zCH2WauXgOu090vC6PFkNKrhY5cfKdypGZs=";

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    # Upstream provides no stable `--version`; just ensure the built binary can run.
    $GOPATH/bin/proxima5 -h >/dev/null

    runHook postCheck
  '';

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
    install -Dm444 LICENSE -t $out/share/licenses/${finalAttrs.pname}
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Retro-style terminal space shooter";
    homepage = "https://github.com/gdamore/proxima5";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "proxima5";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
