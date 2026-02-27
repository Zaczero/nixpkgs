{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnu-conquest";
  version = "1.03";

  src = fetchurl {
    url = "mirror://sourceforge/gnu-conquest/gnu-conquest/${finalAttrs.version}/gnu-conquest-${finalAttrs.version}.tar.gz";
    hash = "sha256-cLz5L3OShZK68DoXbf8Bc0AKTiT6hJSe6buUeWBI1es=";
  };

  strictDeps = true;

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ ncurses ];

  postPatch = ''
    # Newer C++ compilers reject this redundant forward declaration inside the
    # class body: it redeclares Conquest_Server::Server with different access.
    # The proper forward declaration already exists at namespace scope above.
    substituteInPlace src/conquest_server_client.hpp --replace-fail \
      $'    class Conquest_Server::Server;\n' \
      ""
  '';

  hardeningDisable = [ "format" ];

  # Historical C++ sources assume pre-C++11 libstdc++ iostream conversions and
  # also rely on implicit <cstring> includes for memset(). Keep the sources
  # untouched by building in a compatible mode instead of patching.
  preConfigure = ''
    export CXXFLAGS+=" -std=gnu++03 -include cstring -include cstdio -include pthread.h"
  '';

  # No stable non-interactive self-test; the server can block waiting for clients.
  doCheck = false;

  postInstall = ''
    install -Dm644 AUTHORS ChangeLog NEWS README -t $out/share/doc/gnu-conquest/
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=skip" ];

  };
  meta = {
    description = "Networked version of the Conquest strategy game (client/server)";
    homepage = "https://sourceforge.net/projects/gnu-conquest/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "conquest_client";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
