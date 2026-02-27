{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ularn";
  version = "0-unstable-2025-02-09";

  src = fetchFromGitHub {
    owner = "ularn";
    repo = "ularn";
    rev = "ef421842add954c55639656c5973042963c9b258";
    hash = "sha256-+hedzi7ZwV2J3iN790gyiSLGlHTkA0gGhrQgXaCfx8E=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    ncurses
  ];

  NIX_CFLAGS_COMPILE = [
    "-std=gnu89"
    "-Wno-error=implicit-int"
    "-Wno-error=implicit-function-declaration"
  ];

  preConfigure = ''
    export LIBS="-lncurses -ltinfo"
  '';

  postPatch = ''
    # Modern toolchains don't accept K&R-style duplicate prototypes for `fortune`.
    substituteInPlace src/extern.h \
      --replace-fail "char *fortune();" "" \
      --replace-fail "char *fortune(char *);" "char *fortune(char *);"

    substituteInPlace src/action.c \
      --replace-fail "char *fortune(), *p;" "char *p;"

    substituteInPlace src/object.c \
      --replace-fail "char *fortune(), *p;" "char *p;"
  '';

  postInstall = ''
    install -Dm644 LICENSE -t $out/share/licenses/${finalAttrs.pname}
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Ularn: classic roguelike game (curses)";
    homepage = "https://github.com/ularn/ularn";
    license = lib.licenses.gpl2Plus;
    mainProgram = "Ularn";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
