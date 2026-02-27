{
  lib,
  stdenv,
  fetchurl,
  ncurses,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nettoe";
  version = "1.5.1";

  src = fetchurl {
    url = "mirror://sourceforge/nettoe/nettoe-${finalAttrs.version}.tar.gz";
    hash = "sha256-28LAjn4PfmAjaVTuGaFlo1CrPgvLvghezWh/OSU4gcs=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--enable-desktop"
    "--enable-menu"
  ];

  NIX_CFLAGS_COMPILE = [ "-fcommon" ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  versionCheckProgramArg = "--version";

  postInstall = ''
    install -Dm644 -t $out/share/doc/${finalAttrs.pname} \
      README AUTHORS ChangeLog NEWS BUGS TO-DO protocol.txt

    install -Dm644 -t $out/share/licenses/${finalAttrs.pname} COPYING
  '';

  meta = {
    description = "Networked Tic-Tac-Toe in the terminal";
    homepage = "https://nettoe.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "nettoe";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
