{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  check,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hinversi";
  version = "0.8.2";

  src = fetchurl {
    url = "mirror://sourceforge/hinversi/latest/hinversi-${finalAttrs.version}.tar.gz";
    hash = "sha256-7uReCaYmfS9dD2RDZ0eUkEBHJfSPM7KFxSarq4BWfEo=";
  };

  strictDeps = true;

  nativeBuildInputs = [ pkg-config ];
  nativeCheckInputs = [ check ];

  NIX_CFLAGS_COMPILE = [ "-std=gnu89" ];

  postPatch = ''
    # GCC treats K&R-style empty-parameter declarations as prototypes here,
    # so passing an argument is a hard error. The function takes no args.
    substituteInPlace lib/aiManager.c \
      --replace-fail "simple_setAIName(color)" "simple_setAIName()"
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  postInstall = ''
    install -Dm644 AUTHORS ChangeLog COPYING NEWS README -t $out/share/doc/hinversi
    ln -s hinversi-cli $out/bin/hinversi
  '';

  meta = {
    description = "Reversi (Othello) engine and CLI";
    homepage = "https://sourceforge.net/projects/hinversi/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "hinversi";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
