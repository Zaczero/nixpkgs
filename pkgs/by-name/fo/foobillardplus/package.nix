{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  pkg-config,
  SDL,
  SDL_mixer,
  SDL_net,
  freetype,
  libpng,
  zlib,
  libGL,
  libGLU,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "foobillardplus";
  version = "3.42beta";

  src = fetchurl {
    url = "mirror://sourceforge/foobillardplus/source/foobillardplus-${finalAttrs.version}.tar.gz";
    hash = "sha256-4na3BnSn14jEXu/4nx9dtdSNhxoauSEDgT1CSjdh4dk=";
  };

  strictDeps = true;

  doCheck = false;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  postPatch = ''
        # Remove prefix mangling
        substituteInPlace configure.in \
          --replace-fail 'prefix=$prefix/foobillardplus' 'prefix=$prefix' \
          --replace-fail 'datadir=$prefix/data' 'datadir=$prefix/share/foobillardplus/data'

        # Fix data directory discovery
        substituteInPlace src/sys_stuff.c \
          --replace-fail 'strncpy(slash_pos, "/data"' 'strncpy(slash_pos, "/share/foobillardplus/data"'

        substituteInPlace src/Makefile.am \
          --replace-fail '`sdl-config --cflags`' "$(pkg-config --cflags sdl SDL_mixer SDL_net)" \
          --replace-fail '`sdl-config --libs`' "$(pkg-config --libs sdl SDL_mixer SDL_net)" \
          --replace-fail '`freetype-config --cflags`' "$(pkg-config --cflags freetype2)" \
          --replace-fail '`freetype-config --libs`' "$(pkg-config --libs freetype2)"
        substituteInPlace src/vmath.c \
          --replace-fail '#include "vmath.h"' '#include <stdlib.h>
    #include <math.h>
    #include "vmath.h"' \
          --replace-fail "inline float" "float" \
          --replace-fail "abs(y)" "fabsf(y)"
        substituteInPlace src/vmath.h \
          --replace-fail "inline float" "float"
  '';

  buildInputs = [
    SDL
    SDL_mixer
    SDL_net
    freetype
    libpng
    zlib
    libGL
    libGLU
  ];

  postInstall = ''
    install -d $out/share/doc/foobillardplus
    mv $out/AUTHORS $out/ChangeLog $out/COPYING \
       $out/INSTALL $out/README $out/TODO \
       $out/share/doc/foobillardplus/
    install -d $out/share/applications
    mv $out/foobillardplus.desktop $out/share/applications/
    install -d $out/share/pixmaps
    mv $out/foobillardplus.png $out/share/pixmaps/
    rm $out/foobillardplus.xbm
  '';

  meta = {
    description = "OpenGL billiard game";
    homepage = "https://foobillardplus.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "foobillardplus";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
