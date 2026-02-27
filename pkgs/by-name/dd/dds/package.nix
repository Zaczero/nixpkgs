{
  lib,
  stdenv,
  fetchzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dds";
  version = "2.9.0";

  src = fetchzip {
    url = "https://privat.bahnhof.se/wb758135/bridge/dds290-src.zip";
    hash = "sha256-R2j0PVQggDZyD61cvgAUi4ExUQlAlkuP3EoU2K237WQ=";
  };

  strictDeps = true;

  outputs = [
    "out"
    "dev"
  ];

  buildPhase = ''
    runHook preBuild

    cd src

    export NIX_LDFLAGS=

    make -f Makefiles/Makefile_linux_shared linux \
      CC="$CXX" \
      THREADING="-DDDS_THREADS_STL" \
      THREAD_COMPILE="" \
      THREAD_LINK="-pthread" \
      COMPILE_FLAGS="$NIX_CFLAGS_COMPILE -fPIC -O2 -std=c++11 -pthread" \
      LINK_FLAGS="-shared -Wl,--as-needed -Wl,-z,relro -pthread -fPIC"

    cd ..

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 src/libdds.so -t "$out/lib"

    install -Dm644 include/dll.h -t "$dev/include"
    install -Dm644 include/portab.h -t "$dev/include"
    install -Dm644 src/dds.h -t "$dev/include"

    install -d "$dev/lib/pkgconfig"
    cat > "$dev/lib/pkgconfig/dds.pc" <<EOF
    prefix=$out
    libdir=\''${prefix}/lib
    includedir=$dev/include

    Name: dds
    Description: Double dummy solver for bridge hands
    Version: ${finalAttrs.version}
    Libs: -L\''${libdir} -ldds
    Cflags: -I\''${includedir}
    EOF

    install -Dm644 ChangeLog LICENSE README.md -t "$out/share/doc/dds"

    runHook postInstall
  '';

  meta = {
    description = "Double dummy solver for bridge hands (DDS)";
    homepage = "https://privat.bahnhof.se/wb758135/bridge/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ Zaczero ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
