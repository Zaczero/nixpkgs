{
  lib,
  stdenv,
  fetchzip,
  cmake,
  pkg-config,
  SDL2,
  SDL2_ttf,
  libpng,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "freerct";
  version = "0.1";

  src = fetchzip {
    url = "https://freerct.net/public/release/${finalAttrs.version}/${finalAttrs.version}.zip";
    hash = "sha256-kftKFB/78LR6aO1ey8G3JQIVfdvp3lS7J9c5gpnw/Os=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [
    SDL2
    SDL2_ttf
    libpng
  ];

  cmakeFlags = [ "-DVERSION_STRING=${finalAttrs.version}" ];

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      "cmake_minimum_required(VERSION 2.8)" \
      "cmake_minimum_required(VERSION 3.5)"
  '';

  postInstall = ''
    install -Dm644 ../CONTRIBUTORS.rst ../README.rst -t $out/share/doc/freerct/
    cp -a ../developer_documentation $out/share/doc/freerct/
  '';

  meta = {
    description = "Open-source RollerCoaster Tycoon-style game";
    homepage = "https://freerct.net/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "freerct";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
