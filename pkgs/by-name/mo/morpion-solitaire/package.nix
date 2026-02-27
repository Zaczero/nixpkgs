{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "morpion-solitaire";
  version = "0-unstable-2020-05-05";

  src = fetchFromGitHub {
    owner = "gre";
    repo = "morpion-solitaire";
    rev = "187d2c68f0c932db8bd5e14224f9f407a7fd1c3c";
    hash = "sha256-WklN5/V13qBQjw1W5VfMiVSB8qa34IeUm9UZJV/4w4Q=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  buildPhase = ''
    runHook preBuild

    $CC $CPPFLAGS $CFLAGS \
      -o morpion-solitaire \
      *.c \
      $LDFLAGS -lncurses -lm

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 morpion-solitaire -t "$out/bin"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 "$src/README" -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 "$src/LICENSE" -t "$out/share/licenses/${finalAttrs.pname}"
  '';

  # Interactive ncurses game without a stable non-interactive mode.

  NIX_CFLAGS_COMPILE = [ "-Wno-error=format-security" ];

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Morpion solitaire terminal game";
    homepage = "https://github.com/gre/morpion-solitaire";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "morpion-solitaire";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
