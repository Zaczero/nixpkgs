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
    url = "https://productionresultssa15.blob.core.windows.net/actions-results/4fa0e244-2fca-462c-bb3d-a1c5d6eebd1f/workflow-job-run-a8c9ebc3-7f02-56fe-b41f-a414c20cd398/artifacts/5dcad2b616229407ec7f33888601409dd74602a8f8c599130e9fbb953b8638fe.zip?rscd=attachment%3B+filename%3D%22zen.source.tar.zst.zip%22&se=2025-09-28T20%3A53%3A14Z&sig=mkM4o%2BhH0A%2Fpr%2FD%2BXfPi0iAv8xw41RnxDB2zLYvezqU%3D&ske=2025-09-29T06%3A50%3A51Z&skoid=ca7593d4-ee42-46cd-af88-8b886a2f84eb&sks=b&skt=2025-09-28T18%3A50%3A51Z&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skv=2025-11-05&sp=r&spr=https&sr=b&st=2025-09-28T20%3A43%3A09Z&sv=2025-11-05";
  };

  unpackPhase = "unzip $src && tar -I zstd -xf zen.source.tar.zst && rm zen.source.tar.zst";

  extraNativeBuildInputs = [ zstd ];

  meta = {
    description = "Firefox fork focused on productivity, privacy, and clean design";
    homepage = "https://zen-browser.app";
    changelog = "https://github.com/zen-browser/desktop/releases/tag/${sources.version}";
    license = with lib.licenses; [
      mpl20
      mit
    ];
    platforms = lib.platforms.unix;
    mainProgram = "zen";
    maxSilent = 14400;
    maintainers = with lib.maintainers; [ Zaczero ];

    # since Firefox 60, build on 32-bit platforms fails with "out of memory".
    # not in `badPlatforms` because cross-compilation on 64-bit machine might work.
    broken = stdenv.buildPlatform.is32bit;
  };

  #updateScript = updateScriptDrv;
}).overrideAttrs
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
