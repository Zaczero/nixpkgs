{
  stdenv,
  stdenvNoCC,
  lib,
  gnutar,
  callPackage,
  buildMozillaMach,
  versionCheckHook,
  fetchNpmDeps,
  fetchurl,
  zstd,
  rustPlatform,
  python3,
  prefetch-npm-deps,
  buildNpmPackage,
}:

let
  sources = lib.importJSON ./sources.json;
  # updateScriptDrv = callPackage ./update.nix {
  #   attrPath = "zen-browser-unwrapped";
  # };
in
(
(buildMozillaMach {
  pname = "zen-browser";
  inherit (sources) version packageVersion;

  binaryName = "zen";
  applicationName = "Zen";
  branding = "browser/branding/release";
  requireSigning = false;
  allowAddonSideload = true;

  src = fetchurl {
    inherit (sources) hash;
    #url = "https://github.com/zen-browser/desktop/releases/download/${sources.version}/zen.source.tar.zst";
      url = "https://productionresultssa5.blob.core.windows.net/actions-results/302591ca-fd2b-4ac7-a0f1-69870e081be4/workflow-job-run-7e947fc8-4a71-5736-9864-23974f301f37/artifacts/5dcad2b616229407ec7f33888601409dd74602a8f8c599130e9fbb953b8638fe.zip?rscd=attachment%3B+filename%3D%22zen.source.tar.zst.zip%22&se=2025-09-29T14%3A21%3A51Z&sig=nVmi8piZ4xfzySTFqQTj0%2B061leOHFureLdY7bYnnf4%3D&ske=2025-09-30T02%3A10%3A32Z&skoid=ca7593d4-ee42-46cd-af88-8b886a2f84eb&sks=b&skt=2025-09-29T14%3A10%3A32Z&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skv=2025-11-05&sp=r&spr=https&sr=b&st=2025-09-29T14%3A11%3A46Z&sv=2025-11-05";
  };

  unpackPhase = "unzip $src && tar -I zstd -xf zen.source.tar.zst && rm zen.source.tar.zst";

  extraNativeBuildInputs = [ zstd ];

  meta = {
    description = "Firefox fork focused on productivity, privacy, and clean design";
    homepage = "https://zen-browser.app";
    changelog = "https://github.com/zen-browser/desktop/releases/tag/${sources.version}";
      license = lib.licenses.mpl20;
    platforms = lib.platforms.unix;
    mainProgram = "zen";
    maxSilent = 14400;
    maintainers = with lib.maintainers; [ Zaczero ];

    # since Firefox 60, build on 32-bit platforms fails with "out of memory".
    # not in `badPlatforms` because cross-compilation on 64-bit machine might work.
    broken = stdenv.buildPlatform.is32bit;
  };

  #updateScript = updateScriptDrv;
  }).override
  {
    # disable PGO support as the profilingPhase is broken.
    # reading of the sources indicated that Zen Browser does not support it.
    pgoSupport = false;

    # crashreporter is not available in Zen Browser.
    # https://github.com/zen-browser/desktop/blob/2abba4d2668111f44565e4d6d480b4900a77e644/configs/common/mozconfig#L96
    crashreporterSupport = false;
  }
).overrideAttrs
  (old: {
    # version = sources.version;
    # __intentionallyOverridingVersion = true;
    sourceRoot = ".";

    passthru.updateScript = ./update.sh;

    # nativeInstallCheckInputs = (old.nativeInstallCheckInputs or [ ]) ++ [ versionCheckHook ];
    # versionCheckProgramArg = "--version";
    # passthru = (old.passthru or { }) // {
    #   inherit (sources) packageVersion;
    #   zenVersion = sources.version;
    # };
  })
