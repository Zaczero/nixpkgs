{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "wordle-cli";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "nimblebun";
    repo = "wordle-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pJJiGUN1qflCQw+gSEEg8Q1HeTXaC1jgmHYoAbLk/Co=";
  };

  strictDeps = true;

  vendorHash = "sha256-+8SIvfQ50FvyNl3ECzgQFFydE1UcQfJrcmApK7Zq3Lc=";

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 LICENSE -t $out/share/licenses/${finalAttrs.pname}
  '';

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
      command = "TERM=dumb wordle-cli --version";
      version = finalAttrs.version;
    };
  };

  meta = {
    description = "Play Wordle in your terminal";
    homepage = "https://github.com/nimblebun/wordle-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "wordle-cli";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
