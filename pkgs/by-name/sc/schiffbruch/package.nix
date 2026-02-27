{
  lib,
  buildPackages,
  stdenv,
  cmake,
  ninja,
  fetchFromGitHub,
  nix-update-script,
  sfml_2,
}:

stdenv.mkDerivation (
  finalAttrs:
  let
    resgen = buildPackages.stdenv.mkDerivation {
      pname = "${finalAttrs.pname}-resgen";
      inherit (finalAttrs) version src;

      sourceRoot = "${finalAttrs.src.name}/tools/resgen";

      strictDeps = true;

      buildPhase = ''
        runHook preBuild

        $CXX $CPPFLAGS $CXXFLAGS -std=c++17 -o resgen main.cpp $LDFLAGS ${lib.optionalString buildPackages.stdenv.cc.isGNU "-lstdc++fs"}

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        install -Dm755 resgen -t $out/bin

        runHook postInstall
      '';
    };
  in
  {
    pname = "schiffbruch";
    version = "1.2.1";

    src = fetchFromGitHub {
      owner = "sandsmark";
      repo = "Schiffbruch";
      rev = "066d28b53a6560e6949de60d0d119164c49978fa";
      hash = "sha256-7YwjcLpc2c4ocGMYVrilX3jEThcqUV0OoX+Abh1GPGc=";
    };

    strictDeps = true;

    postPatch = ''
      # Fix build failure with modern compilers: `GetPixel()` used `img` before a
      # null check, and accessed `rgbStruct` before it was declared.
      substituteInPlace src/Renderer.cpp \
        --replace-fail $'    // TODO: more efficient\n    if (x < 0 || y < 0 || x >= int(img->getSize().x) || y >= int(img->getSize().y)) {\n        rgbStruct.r = 0;\n        return{};\n    }\n    if (!img) {\n        return{};\n    }\n    RGBSTRUCT rgbStruct;' \
        $'    // TODO: more efficient\n    if (!img) {\n        return{};\n    }\n\n    RGBSTRUCT rgbStruct;\n\n    if (x < 0 || y < 0 || x >= int(img->getSize().x) || y >= int(img->getSize().y)) {\n        rgbStruct.r = 0;\n        rgbStruct.g = 0;\n        rgbStruct.b = 0;\n        return rgbStruct;\n    }'
    '';

    nativeBuildInputs = [
      cmake
      ninja
      resgen
    ];

    buildInputs = [
      sfml_2
    ];

    cmakeFlags = [
      (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release")
      (lib.cmakeFeature "CMAKE_MODULE_PATH" "${sfml_2}/share/SFML/cmake/Modules/")
    ];

    preConfigure = ''
      export CXXFLAGS+=" -include cstdint"
    '';

    postInstall = ''
      install -Dm644 ../README.md -t $out/share/doc/${finalAttrs.pname}
      install -Dm644 ../LICENSE -t $out/share/licenses/${finalAttrs.pname}
    '';

    # GUI game without stable non-interactive mode.

    passthru.updateScript = nix-update-script { };

    meta = {
      description = "Modern port of the 1999 German game Schiffbruch";
      homepage = "https://github.com/sandsmark/Schiffbruch";
      license = lib.licenses.cc-by-40;
      maintainers = with lib.maintainers; [ Zaczero ];
      mainProgram = "schiffbruch";
      sourceProvenance = with lib.sourceTypes; [ fromSource ];
      platforms = lib.platforms.unix;
    };
  }
)
