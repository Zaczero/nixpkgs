{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  gtk2,
  openal,
  freealut,
  libvorbis,
  xorg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spacezero";
  version = "0.86.01";

  src = fetchurl {
    url = "mirror://sourceforge/spacezero/spacezero%200.86/spacezero-${finalAttrs.version}.tar.gz";
    hash = "sha256-hYinMFHjXjXm2RI7W+s581dGI8ZOjcTzO05PMAO3MpY=";
    name = "${finalAttrs.pname}-${finalAttrs.version}.tar.gz";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    gtk2
    openal
    freealut
    libvorbis
    xorg.libX11
  ];

  postPatch = ''
    # Upstream ships duplicate function prototypes, which breaks with modern C compilers.
    # Keep the actually-implemented signature.
    substituteInPlace include/randomnamegen.h \
      --replace-fail $'\r' "" \
      --replace-fail $'char *getRandomName();\n' ""
  '';

  preBuild = ''
    export HOME="$TMPDIR"
  '';

  buildPhase = ''
    runHook preBuild

    make \
      CC="${stdenv.cc.targetPrefix}cc" \
      INSTALL_DIR="$out/bin" \
      INSTALL_DATA_DIR="$out/share/${finalAttrs.pname}" \
      CFLAGS='-Wall --pedantic -fno-common -I./include -DDATADIR=\"./dat\" -DINSTALL_DATA_DIR=\"'"$out"'/share/${finalAttrs.pname}\" -std=gnu89'

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    strings ./bin/spacezero | grep -Fq "Usage is: spacezero"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    make install \
      INSTALL_DIR="$out/bin" \
      INSTALL_DATA_DIR="$out/share/${finalAttrs.pname}"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 changelog -t $out/share/doc/${finalAttrs.pname}
    cp -a html $out/share/doc/${finalAttrs.pname}/

    install -Dm644 COPYING -t $out/share/licenses/${finalAttrs.pname}
  '';

  meta = {
    description = "Real-time strategy 2D space combat game";
    homepage = "http://spacezero.sourceforge.net/";
    license = lib.licenses.gpl3Only;
    mainProgram = "spacezero";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
