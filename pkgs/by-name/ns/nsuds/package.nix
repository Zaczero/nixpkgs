{
  lib,
  stdenv,
  fetchurl,
  ncurses,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nsuds";
  version = "0.7B";

  src = fetchurl {
    url = "mirror://sourceforge/nsuds/nsuds/nsuds-${finalAttrs.version}/nsuds-${finalAttrs.version}.tar.gz";
    hash = "sha256-bZs+U/PPRemqKfdC9qP3vIOhKQCZpi2bi6Qhh5B2km4=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  configureFlags = [
    "--disable-setgid"
  ];

  postPatch = ''
    # Upstream defaults to ${placeholder "out"}/var/games/nsuds for the score
    # file location, but Nix store outputs are immutable. nsuds only reads the
    # shipped `high_scores` file (no writing), so install it into $out/share and
    # compile the runtime path accordingly.
    substituteInPlace src/Makefile.in \
      --replace-fail '$(localstatedir)/games/$(PACKAGE)/' '$(datadir)/$(PACKAGE)/' \
      --replace-fail 'highscoredir = $(localstatedir)/games/$(PACKAGE)' 'highscoredir = $(datadir)/$(PACKAGE)'

    # Don’t attempt to chgrp/chmod to games/root inside the build sandbox.
    substituteInPlace src/Makefile.in \
      --replace-fail 'chgrp games $(DESTDIR)$(bindir)/nsuds' 'true' \
      --replace-fail 'chmod 2555  $(DESTDIR)$(bindir)/nsuds' 'true' \
      --replace-fail 'chmod 0555  $(DESTDIR)$(bindir)/nsuds' 'true' \
      --replace-fail 'chgrp games $(DESTDIR)$(datadir)/$(PACKAGE)/high_scores' 'true'
  '';

  NIX_CFLAGS_COMPILE = [
    "-Wno-error=format-security"
    "-fcommon"
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  versionCheckProgramArg = "-v";

  postInstall = ''
    # Preserve upstream documentation for the “historical museum”.
    install -Dm644 AUTHORS ChangeLog NEWS README INSTALL -t "$out/share/doc/${finalAttrs.pname}"

    # Canonical license location.
    install -Dm644 COPYING -t "$out/share/licenses/${finalAttrs.pname}"

    # Default high score list is installed by upstream make rules into
    # $out/share/nsuds/high_scores; SCOREDIR is patched accordingly.
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=skip" ];

  };
  meta = {
    description = "Ncurses Sudoku System";
    homepage = "https://sourceforge.net/projects/nsuds/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "nsuds";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
