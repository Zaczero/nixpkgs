{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  autoreconfHook,
  pkg-config,
  ncurses,
  SDL,
  SDL_mixer,
  SDL_image,
  SDL_ttf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mediocrity";
  version = "1.0.1";

  src = fetchurl {
    url = "https://web.archive.org/web/20131205100524/http://www.cavein.org/~chris/code/tower/mediocrity-${finalAttrs.version}.tar.bz2";
    hash = "sha256-5JUCyqh+nCSka0zjes1CdjdYHbHGc1qMOHTPz2pBSKQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    buildPackages.stdenv.cc
    buildPackages.SDL
  ];

  buildInputs = [
    ncurses
    SDL
    SDL_mixer
    SDL_image
    SDL_ttf
  ];

  NIX_CFLAGS_COMPILE = toString [
    "-I${lib.getDev SDL}/include/SDL"
    "-I${lib.getDev SDL_mixer}/include/SDL"
    "-I${lib.getDev SDL_image}/include/SDL"
    "-I${lib.getDev SDL_ttf}/include/SDL"
  ];

  configureFlags = [
    "--enable-sdl"
  ];

  postInstall = ''
    install -Dm644 README INSTALL NEWS -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 COPYING -t "$out/share/licenses/${finalAttrs.pname}"
  '';

  meta = {
    description = "Tower defense game (Tower of Mediocrity) with ncurses and optional SDL UI";
    homepage = "https://web.archive.org/web/20131205100524/http://www.cavein.org/~chris/code/tower/";
    license = lib.licenses.gpl3Plus;
    mainProgram = "mediocrity-sdl";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
