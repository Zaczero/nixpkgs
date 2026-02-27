{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnupong";
  version = "0.14";

  src = fetchurl {
    url = "mirror://ibiblioPubLinux/games/arcade/gnupong-${finalAttrs.version}.tar.gz";
    hash = "sha256-lp3QDDaVWYPHsB/auvWqvRaTiojMrMeuqWRNs+yCWAY=";
  };

  strictDeps = true;

  sourceRoot = ".";

  buildInputs = [
    ncurses
  ];

  dontConfigure = true;

  postPatch = ''
    # Upstream predates `std::cout` and relies on old libstdc++ exporting `cout`
    # in the global namespace. Avoid editing upstream sources by injecting a
    # tiny compat header at compile time.
    cat > nixpkgs-compat.hpp <<'EOF'
    #include <iostream>
    using namespace std;
    EOF
  '';

  buildPhase = ''
    runHook preBuild

    $CXX $CPPFLAGS $CXXFLAGS -include nixpkgs-compat.hpp -o pong pong.cpp $LDFLAGS -lncurses

    runHook postBuild
  '';

  # `pong` initializes curses immediately (before argument parsing), so there’s
  # no reliable non-interactive `--help/--version` check we can run.

	  installPhase = ''
	    runHook preInstall

	    install -Dm755 pong -t "$out/bin"

	    # Preservation of documentation
	    install -Dm644 AUTHORS -t "$out/share/doc/${finalAttrs.pname}"
	    install -Dm644 COPYING -t "$out/share/licenses/${finalAttrs.pname}"

	    runHook postInstall
	  '';

  meta = {
    description = "Ncurses pong clone";
    homepage = "https://www.ibiblio.org/pub/linux/games/arcade/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "pong";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
