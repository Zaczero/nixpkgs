{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  curl,
  enet,
  fontconfig,
  freetype,
  gnumake,
  lua5_4,
  nix-update-script,
  pkg-config,
  SDL2,
  xorg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "knights";
  version = "0-unstable-2025-12-23";

  src = fetchFromGitHub {
    owner = "sdthompson1";
    repo = "knights";
    rev = "57ead2f3ebaf36ad8ad5f187c4cddc0787b551c5";
    hash = "sha256-55hvnCfOpVrzPYMlxbpaN0DrhLzH0nbvjPf9Q/PVLJc=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gnumake
    pkg-config
  ];

  buildInputs = [
    boost
    curl
    enet
    fontconfig
    freetype
    lua5_4
    SDL2
    xorg.libX11
  ];

  buildPhase = ''
    runHook preBuild

    make -j $NIX_BUILD_CORES \
      PREFIX="$out" \
      CC="$CC" \
      CXX="$CXX" \
      LUA_CFLAGS="$(pkg-config lua --cflags) -include lua.hpp" \
      LUA_LIBS="$(pkg-config lua --libs)"

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck

    output="$(./knights --version || true)"
    grep -Fq "Knights version 028" <<<"$output"

    output="$(./knights_server --version || true)"
    grep -Fq "Knights Server version 028" <<<"$output"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    make install PREFIX="$out"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README.txt README-SDL.txt -t $out/share/doc/knights
    cp -a lua_docs $out/share/doc/knights/
    cp -a amiga_knights $out/share/doc/knights/
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Multiplayer dungeon bashing game (open source version)";
    homepage = "https://www.knightsgame.org.uk/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "knights";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
