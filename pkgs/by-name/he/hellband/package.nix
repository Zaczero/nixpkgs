{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  ncurses5,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hellband";
  version = "0-unstable-2013-04-19";

  src = fetchFromGitHub {
    owner = "nickmcconnell";
    repo = "AngbandPlus";
    rev = "e1a35ed2cd6a2cf008d01957f891e9bae9af6480";
    hash = "sha256-daZO/T41qme8a05cJarogQpoBML/o2lpOtBxKCGEFlM=";
  };

  strictDeps = true;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ ncurses5 ];

  buildPhase = ''
    runHook preBuild
    make -C src -f makefile.org \
      CC=${stdenv.cc.targetPrefix}cc \
      CFLAGS="${
        lib.concatStringsSep " " [
          "-O2"
          "-pipe"
          "-fcommon"
          "-D\"USE_GCU\""
          "-D\"USE_NCURSES\""
          "-D_XOPEN_SOURCE=600"
          "-D_DEFAULT_SOURCE"
          "-std=c99"
          "-I${lib.getDev ncurses5}/include"
        ]
      }" \
      LDFLAGS="" \
      LIBS="-L${lib.getLib ncurses5}/lib -lncurses"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 src/hellband -t $out/bin
    install -Dm644 hellband.cfg hellband.ini -t $out/share/hellband
    cp -a lib $out/share/hellband/
    wrapProgram $out/bin/hellband --set ANGBAND_PATH $out/share/hellband
    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 -t $out/share/doc/${finalAttrs.pname} \
      README.md changes.txt gdb-notes.md COPYING.txt LICENSE
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Roguelike variant based on Angband";
    homepage = "https://hellband.org/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "hellband";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
