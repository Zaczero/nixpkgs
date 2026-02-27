{
  lib,
  stdenv,
  buildPackages,
  fetchFromGitHub,
  bison,
  flex,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  cairo,
  fontconfig,
  freetype,
  librsvg,
  ncurses,
  xorg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kgames";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "keith-packard";
    repo = "kgames";
    tag = finalAttrs.version;
    hash = "sha256-2JW11YEpCTybF2S/KOww1QGfVGxldwZW2f9bDr9WVCU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    bison
    flex
    meson
    ninja
    pkg-config
    buildPackages.stdenv.cc
  ];

  postInstall = ''
    install -Dm644 ../README -t $out/share/doc/kgames
    install -Dm644 ../COPYING -t $out/share/doc/kgames
    install -Dm644 ../xmille/README -t $out/share/doc/kgames/xmille
  '';

  buildInputs = [
    cairo
    fontconfig
    freetype
    librsvg
    ncurses
    xorg.libX11
    xorg.libXaw
    xorg.libXft
    xorg.libXmu
    xorg.libXpm
    xorg.libXrender
    xorg.libXt
  ];

  postPatch = ''
    chmod +x kdominos/make-dominos-svg
    patchShebangs .
  '';

  mesonFlags = [
    "-Duser-menu=false"
    "-Dmenudir=${placeholder "out"}/etc/xdg/menus/applications-merged"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Collection of classic X11 card and board games";
    homepage = "https://github.com/keith-packard/kgames";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
