{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  guile_1_8,
  gtk2,
  vte_gtk2,
  ncurses,
  readline,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnurobots";
  version = "1.2.0";

  src = fetchurl {
    url = "mirror://gnu/gnurobots/gnurobots-${finalAttrs.version}.tar.gz";
    hash = "sha256-i29PDUC+9c/ft+t8guoUAtJ0fDeyx7eqkvr/VTUd8R0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    guile_1_8
  ];
  buildInputs = [
    guile_1_8
    gtk2
    vte_gtk2
    ncurses
    readline
  ];
  NIX_CFLAGS_COMPILE = [
    "-Wno-error"
    "-Wno-incompatible-pointer-types"
    "-I${lib.getDev readline}/include/readline"
    "-std=gnu89"
  ];

  preConfigure = ''
    substituteInPlace configure --replace-fail 'CFLAGS="-pedantic-errors -Werror -Wall -g"' ""
    export GUILE_CONFIG=${guile_1_8}/bin/guile-config
    export GUILE_TOOLS=${guile_1_8}/bin/guile-tools
  '';

  postInstall = ''
    install -Dm644 -t $out/share/doc/gnurobots AUTHORS ChangeLog COPYING NEWS README THANKS
  '';

  checkPhase = ''
    runHook preCheck
    ./src/gnurobots --help | grep -Fq "GNU Robots"
    runHook postCheck
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=skip" ];

  };
  meta = {
    description = "Program a robot to find its way out of a maze";
    homepage = "https://www.gnu.org/software/gnurobots/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "gnurobots";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
