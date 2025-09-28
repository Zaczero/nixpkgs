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
    url = "https://github.com/zen-browser/desktop/releases/download/${sources.version}/zen.source.tar.zst";
  };

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

    # nativeInstallCheckInputs = (old.nativeInstallCheckInputs or [ ]) ++ [ versionCheckHook ];
    # versionCheckProgramArg = "--version";
    # passthru = (old.passthru or { }) // {
    #   inherit (sources) packageVersion;
    #   zenVersion = sources.version;
    # };
  })
