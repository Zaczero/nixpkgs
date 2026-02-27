{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "robohack";
  version = "0-unstable-2010-06-29";

  src = fetchFromGitHub {
    owner = "gmn";
    repo = "Robohack";
    rev = "4bf31dec8854347c7dfa8c98c6db4651315de80a";
    hash = "sha256-j9mGQp8hKAkskI/dITl57GDa/C9Bc3i9jvIlvbChVkU=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  buildPhase = ''
    runHook preBuild

    $CC $CPPFLAGS $CFLAGS -Isrc \
      -o robohack \
      src/*.c \
      $LDFLAGS -lncurses

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 robohack -t "$out/bin"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 GPL -t $out/share/licenses/${finalAttrs.pname}
  '';

  # Interactive ncurses game without a stable `--version`/`--help`.

  NIX_CFLAGS_COMPILE = [ "-fcommon" ];

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Arcade-style ncurses shooter inspired by Robotron";
    homepage = "https://github.com/gmn/Robohack";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "robohack";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
