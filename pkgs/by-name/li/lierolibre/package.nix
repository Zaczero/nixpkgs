{
  lib,
  stdenv,
  fetchgit,
  autoreconfHook,
  pkg-config,
  boost,
  imagemagick,
  libconfig,
  SDL,
  SDL_mixer,
  sox,
  zlib,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lierolibre";
  version = "0.5";

  src = fetchgit {
    url = "https://gitlab.com/lierolibre/lierolibre.git";
    rev = "ae584b245fedac3cb7030d8b9591f36632b0f29b";
    hash = "sha256-83cULr2MaWsZFcYEdMue7OkoEPzr3h1ciOlZeIKR+X0=";
    fetchSubmodules = false;
  };

  strictDeps = true;

  postUnpack = ''
    rm -rf "$sourceRoot/data" "$sourceRoot/src/gvl" "$sourceRoot/windows"
    mkdir -p "$sourceRoot/data" "$sourceRoot/src/gvl" "$sourceRoot/windows"

    cp -a ${
      fetchgit {
        url = "https://gitlab.com/lierolibre/lierolibre-data.git";
        rev = "141b495caf7c18d0f92950fdb2df4544dc606b03";
        hash = "sha256-rgH0zMF6KM0aGGvk3anr6+E4aq7zCjA6/4LBx+5+cvc=";
      }
    }/. "$sourceRoot/data"

    cp -a ${
      fetchgit {
        url = "https://gitlab.com/lierolibre/gvl.git";
        rev = "6e53c25a5d079968e23a664830f039bfa64c0ae9";
        hash = "sha256-WQaQr4IHENjXzCcqSXKZf7qWAT/X0QzGZEHdwb/W1DQ=";
      }
    }/. "$sourceRoot/src/gvl"

    chmod -R u+w "$sourceRoot/src/gvl"

    ln -s . "$sourceRoot/src/gvl/gvl"

    cp -a ${
      fetchgit {
        url = "https://gitlab.com/lierolibre/lierolibre-w32depends.git";
        rev = "00e16c97a58109a251a82d60dde2e8d09ea64e91";
        hash = "sha256-oSNASYtx6KwRDKR+FBLsiDoZ42g/20Ff9i+Y3Vb7wlY=";
      }
    }/. "$sourceRoot/windows"

    chmod -R u+w "$sourceRoot/windows"
  '';

  postPatch = ''
    patchShebangs scripts
  '';

  nativeBuildInputs = [
    autoreconfHook
    imagemagick
    pkg-config
    SDL
    sox
  ];

  buildInputs = [
    boost
    libconfig
    SDL
    SDL_mixer
    zlib
  ];

  preConfigure = ''
    export CPPFLAGS="$CPPFLAGS -Isrc/gvl -I${lib.getDev SDL}/include/SDL"
  '';

  aclocalFlags = [
    "-I"
    "${SDL}/share/aclocal"
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck

    output="$(./lierolibre -h 2>&1 || true)"
    grep -Fq "print this help message" <<<"$output"

    runHook postCheck
  '';

  postInstall = ''
    docDir="$out/share/doc/${finalAttrs.pname}"
    install -Dm644 \
      AUTHORS \
      COPYING \
      COPYING_winbin \
      ChangeLog \
      NEWS \
      README \
      README.txt \
      README_linuxbin \
      lgpl-2.1.txt \
      -t "$docDir"
  '';

  passthru.updateScript = gitUpdater {
    url = "https://gitlab.com/lierolibre/lierolibre.git";
    rev-prefix = "lierolibre-";
    allowedVersions = "^[0-9]+\\.[0-9]+$";
  };

  meta = {
    description = "Old-school earthworm action game, a fork of Liero (OpenLiero)";
    homepage = "https://gitlab.com/lierolibre/lierolibre";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "lierolibre";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.aarch64;
  };
})
