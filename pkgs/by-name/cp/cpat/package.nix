{
  lib,
  stdenv,
  fetchzip,
  autoreconfHook,
  ncurses,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cpat";
  version = "1.4.2";

  src = fetchzip {
    url = "mirror://sourceforge/cpat/v${finalAttrs.version}/v${finalAttrs.version}%20source%20code.zip";
    hash = "sha256-ubX8qxIRZyJhHvkRoqiopCvBwrnLurpyv58bGDWeaLo=";
  };

  strictDeps = true;

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ ncurses ];

  hardeningDisable = [ "format" ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  versionCheckProgramArg = "--version";

  postInstall = ''
    install -Dm444 AUTHORS ChangeLog NEWS README -t $out/share/doc/cpat/
  '';

  meta = {
    description = "Curses-based solitaire (Patience) game";
    homepage = "https://sourceforge.net/projects/cpat/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "cpat";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
