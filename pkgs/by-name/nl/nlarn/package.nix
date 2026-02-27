{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  makeWrapper,
  ncurses,
  nix-update-script,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nlarn";
  version = "NLarn-0.7.8";

  src = fetchFromGitHub {
    owner = "nlarn";
    repo = "nlarn";
    rev = "0390d6b6c2617dd28b8a11966393789f241cd139";
    hash = "sha256-aQmCBcbHKqA5q76vvZNLRrdm1OiiWRIeoQfrlRH8RCQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    glib
    ncurses
    zlib
  ];

  makeFlags = [
    "config=release"
  ];

  postPatch = ''
    # Avoid upstream -Werror for modern toolchains while keeping warnings on.
    substituteInPlace Makefile \
      --replace-fail "-Wextra -Werror" "-Wextra"

    # Upstream uses pkg-config in the Makefile, which is inconvenient for
    # cross-compilation. Instead, rely on Nix-provided flags.
    substituteInPlace Makefile \
      --replace-fail '$(shell pkg-config --cflags glib-2.0)' '$(NIX_CFLAGS_COMPILE) -I${glib.dev}/include/glib-2.0 -I${glib.out}/lib/glib-2.0/include' \
      --replace-fail '$(shell pkg-config --libs glib-2.0)' '-L${glib.out}/lib -lglib-2.0' \
      --replace-fail '$(shell pkg-config --libs ncurses panel)' '-L${ncurses.out}/lib -lncursesw -lpanelw'

    substituteInPlace Makefile \
      --replace-fail 'LDFLAGS += -lz -lm' 'LDFLAGS += -L${zlib.out}/lib -lz -lm'
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    ./nlarn -v | grep -F "NLarn version 0.8.0"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 nlarn -t "$out/libexec/nlarn"
    cp -a lib "$out/libexec/nlarn/"

    makeWrapper "$out/libexec/nlarn/nlarn" "$out/bin/nlarn"

    install -d "$out/share"
    ln -s "$out/libexec/nlarn/lib" "$out/share/nlarn"

    install -Dm644 README.md Changelog.md -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 LICENSE -t "$out/share/licenses/${finalAttrs.pname}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern reimplementation of Larn (roguelike)";
    homepage = "https://github.com/nlarn/nlarn";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "nlarn";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
