{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ascii-invaders";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "macdice";
    repo = "ascii-invaders";
    rev = "05685db4b640caafda8f153576f98a691bdbf3dc";
    hash = "sha256-5nl6C5MQCcj/7nAqCendO2WbEgDJBcV5/pKewTl3osk=";
  };

  strictDeps = true;

  buildInputs = [ ncurses ];

  # Upstream uses constant sprite strings as the format argument to mvprintw().
  # With nixpkgs hardening's "format" enabled, this is rejected by
  # -Werror=format-security. Patching every call site would be noisy and
  # doesn't improve safety for this specific case (the strings are not
  # attacker-controlled).
  hardeningDisable = [ "format" ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    # The upstream Makefile uses $(LDFLAGS) directly in the compiler invocation.
    # In nix builds LDFLAGS may contain wrapper-internal flags (like `-rpath`)
    # that GCC doesn't accept, so override it to avoid build failures.
    "LDFLAGS="
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ascii_invaders "$out/bin/ascii-invaders"
    install -Dm644 README.md LICENSE -t "$out/share/doc/ascii-invaders"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "ASCII space invaders game for the terminal";
    homepage = "https://github.com/macdice/ascii-invaders";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "ascii-invaders";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
