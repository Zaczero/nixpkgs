{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  flex,
  pkg-config,
  freeglut,
  libxcrypt,
  libGL,
  libGLU,
  libX11,
  libXi,
  libXmu,
  libXt,
  ncurses,
  SDL2,
  SDL2_mixer,
  zlib,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "conquest";
  version = "9.0.1d";

  src = fetchFromGitHub {
    owner = "jontrulson";
    repo = "conquest";
    rev = "conquest-${finalAttrs.version}";
    hash = "sha256-70R4PW9crfMcRj2/ZxYZNUypMaWNRKknErNF8GX3A0E=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    pkg-config
    SDL2 # for AM_PATH_SDL2
  ];

  buildInputs = [
    freeglut
    libxcrypt
    libGL
    libGLU
    libX11
    libXi
    libXmu
    libXt
    ncurses
    SDL2
    SDL2_mixer
    zlib
  ];

  postPatch = ''
    substituteInPlace src/Makefile.am \
      --replace-fail 'chgrp $(CONQGROUP)' 'true' \
      --replace-fail 'chmod 775 $(DESTDIR)$(CONQLOCALSTATEDIR)' 'true' \
      --replace-fail 'chmod g+s' 'true' \
      --replace-fail '-$(bindir)/conqoper$(EXEEXT) -C' 'true' \
      --replace-fail 'chown root:$(CONQGROUP)' 'true'
  '';

  env.NIX_CFLAGS_COMPILE = "-I${lib.getDev SDL2_mixer}/include/SDL2";

  configureFlags = [
    "--with-conquest-group=root"
  ];

  doCheck = false;

  postInstall = ''
    install -Dm444 README.md -t $out/share/doc/conquest/
    install -Dm444 docs/*.md -t $out/share/doc/conquest/
    install -Dm444 docs/*.txt -t $out/share/doc/conquest/
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=^conquest-(.*)$" ];
  };

  meta = {
    description = "Real-time multi-player space warfare game (Conquest)";
    homepage = "https://github.com/jontrulson/conquest";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "conquest";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
