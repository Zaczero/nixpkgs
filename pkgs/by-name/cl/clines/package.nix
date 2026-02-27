{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "clines";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "veselov";
    repo = "clines";
    rev = "v${finalAttrs.version}";
    hash = "sha256-w4YjNqhJyCKsrG9INXzJMfylIrtRIipWG9lhUezAlCw=";
  };

  strictDeps = true;

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [ ncurses ];

  env.NIX_CFLAGS_COMPILE = "-std=gnu89 -Wno-error";

  configureFlags = [ "--with-curses=ncursesw" ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck
    ./clines -h >/dev/null
    runHook postCheck
  '';

  postInstall = ''
    install -Dm644 AUTHORS ChangeLog NEWS README README.md COPYING LICENSE -t "$out/share/doc/clines"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Console lines game";
    homepage = "https://github.com/veselov/clines";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "clines";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
