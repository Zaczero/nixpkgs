{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qcheckers";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "portnov";
    repo = "qcheckers";
    rev = "b4574edb8d1dde158136ca95f81fd2912f958e58";
    hash = "sha256-vHq1b0AczdYGnzxAelkNw37hXSZx/rYBNa79pQzFnxc=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    qt5.qmake
  ]
  # `wrapQtAppsHook` currently fails in cross builds due to mismatched Qt
  # dependencies pulled into the build environment.
  ++ lib.optionals (stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtsvg
  ];

  qmakeFlags = [
    "PREFIX=$(out)"
    "qcheckers.pro"
  ];

  postInstall = ''
    # Canonicalize docs + licenses.
    # Keep runtime assets in $out/share/qcheckers/.
    install -Dm444 "$src/COPYING" -t "$out/share/licenses/${finalAttrs.pname}"
    install -Dm644 "$src/README.md" -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 "$src/INSTALL.md" -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 "$src/FAQ" -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 "$src/NEWS" -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 "$src/ChangeLog" -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 "$src/AUTHORS" -t "$out/share/doc/${finalAttrs.pname}"

    rm \
      "$out/share/qcheckers/COPYING" \
      "$out/share/qcheckers/ChangeLog" \
      "$out/share/qcheckers/AUTHORS"
  '';

  # The program is a GUI application; it doesn't provide a non-interactive
  # `--version/--help` mode that exits reliably without a display server.

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Qt-based checkers (draughts) board game";
    homepage = "https://portnov.github.io/qcheckers/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "qcheckers";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = qt5.qtbase.meta.platforms;
  };
})
