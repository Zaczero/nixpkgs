{
  lib,
  stdenv,
  fetchurl,
  ncurses,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zeta";
  version = "1.1.4";

  src = fetchurl {
    url = "https://zeta.asie.pl/zeta86-${finalAttrs.version}-src.tar.xz";
    hash = "sha256-OYGildA7jSj3HPSpmJ/RnnYWAIVEKfrEwPlcsFHl4iU=";
  };

  strictDeps = true;

  # The archive unpacks into multiple top-level directories (e.g. `src/`, `tools/`).
  # Use a custom unpack phase so we can treat the build directory itself as the source root.
  unpackPhase = ''
    runHook preUnpack
    tar -xf "$src"
    sourceRoot="$PWD"
    runHook postUnpack
  '';

  nativeBuildInputs = [
    (python3.withPackages (ps: [
      ps.pillow
    ]))
  ];

  buildInputs = [
    ncurses
  ];

  makeFlags = [
    "PLATFORM=unix-curses"
    "VERSION=${finalAttrs.version}"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  postPatch = ''
    # Allow nixpkgs to control the compiler (especially for cross builds).
    substituteInPlace Makefile \
      --replace-fail 'CC = ' 'CC ?= '
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/unix-curses/zeta86 -t "$out/bin"
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 LICENSE -t $out/share/licenses/${finalAttrs.pname}
    runHook postInstall
  '';

  meta = {
    description = "Modernized ZZT engine emulator for multiple platforms (curses build)";
    homepage = "https://zeta.asie.pl/";
    license = lib.licenses.isc;
    mainProgram = "zeta86";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
