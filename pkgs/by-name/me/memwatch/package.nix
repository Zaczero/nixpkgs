{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gettext,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "memwatch";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "0x501D";
    repo = "memwatch";
    rev = "44cd63054f5b4fce6113c7cc1f8dc856d5a68028";
    hash = "sha256-KP7mE2enBd/wuqIS0fWdSYJk1itVPnASQhxk1yKQ764=";
  };

  strictDeps = true;

  passthru.updateScript = nix-update-script { };

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  buildInputs = [
    gettext
    ncurses
  ];

  NIX_CFLAGS_COMPILE = [
    "-DLOCALEDIR=\"${gettext}/share/locale\""
    "-DVERSION=\"${finalAttrs.version}\""
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck
    output="$(./src/memwatch --help)"
    grep -Fq "print help and exit" <<<"$output"
    runHook postCheck
  '';

  postInstall = ''
    install -Dm644 \
      "$src/README.md" \
      "$src/NEWS" \
      -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 "$src/LICENSE" -t "$out/share/licenses/${finalAttrs.pname}"
  '';

  meta = {
    description = "Interactive memory viewer for Linux";
    homepage = "https://github.com/0x501D/memwatch";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "memwatch";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.linux;
  };
})
