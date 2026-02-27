{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fmt,
  catch2_3,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gopnik2";
  version = "1.29.4";

  src = fetchFromGitHub {
    owner = "bolknote";
    repo = "gopnik2";
    rev = "eef951dd4b4921e516921985f0734a7dadbf38a9";
    hash = "sha256-W8qtdMG9D5ZmH7QRZ2EJ0EhDyrtxH/U7lknq1Xq2t4A=";
  };

  strictDeps = true;

  nativeBuildInputs = [ cmake ];
  buildInputs = [
    fmt
    catch2_3
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      $'include(FetchContent)\n\n' \
      $'find_package(fmt REQUIRED)\nfind_package(Catch2 REQUIRED)\n\n'

    substituteInPlace CMakeLists.txt --replace-fail \
      $'# Fetch fmt library\nFetchContent_Declare(\n    fmt\n    GIT_REPOSITORY https://github.com/fmtlib/fmt.git\n    GIT_TAG 12.0.0\n    GIT_SHALLOW    TRUE\n    GIT_PROGRESS   TRUE  \n)\nFetchContent_MakeAvailable(fmt)\n\n' \
      ""

    substituteInPlace CMakeLists.txt --replace-fail \
      $'# Fetch Catch2 library\nFetchContent_Declare(\n    catch2\n    GIT_REPOSITORY https://github.com/catchorg/Catch2.git\n    GIT_TAG v3.11.0\n    GIT_SHALLOW    TRUE\n    GIT_PROGRESS   TRUE     \n)\nFetchContent_MakeAvailable(catch2)\n\n' \
      ""

    substituteInPlace CMakeLists.txt --replace-fail \
      "include(Catch)" \
      "include(${catch2_3}/lib/cmake/Catch2/Catch.cmake)"
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck
    ctest --output-on-failure
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 gop2 $out/bin/gop2
    install -Dm644 ../README.md $out/share/doc/gopnik2/README.md
    install -Dm644 ../LICENSE $out/share/doc/gopnik2/LICENSE
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal roguelike adventure game";
    homepage = "https://github.com/bolknote/gopnik2";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "gop2";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
