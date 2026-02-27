{
  lib,
  stdenv,
  fetchFromGitHub,
  gnumake,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "omega-rpg";
  version = "0-unstable-2019-12-11";

  src = fetchFromGitHub {
    owner = "cwc";
    repo = "OmegaRPG";
    rev = "77eebb6e3dda736414f58414dc4cb4e940294168";
    hash = "sha256-6T4UNpSRAKLiLs5CbXljpE2BSE8NvgQQ/yG8XEMo/0Q=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gnumake
    installShellFiles
    makeWrapper
  ];

  buildInputs = [
    ncurses
  ];

  # OmegaRPG contains code that triggers modern format-security diagnostics (e.g.
  # wprintw(win, userString)). We prefer to preserve this historical code as-is,
  # so we disable the hardening that turns these warnings into errors.
  hardeningDisable = [
    "format"
  ];

  makeFlags = [
    "-C"
    "build/unix"
    "CPP=${stdenv.cc.targetPrefix}c++"
    "LD=${stdenv.cc.targetPrefix}c++"
    "LDFLAGS=-lncurses"
  ];

  # Interactive curses game; no reliable non-interactive self-test mode.

  installPhase = ''
    runHook preInstall

    install -Dm755 build/unix/omega -t "$out/libexec"
    install -Dm644 build/unix/data/* -t "$out/share/${finalAttrs.pname}/data"

    install -Dm644 README.md -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 docs/* -t "$out/share/doc/${finalAttrs.pname}"
    installManPage docs/omega.6

    install -Dm644 data/lgpl.txt -t "$out/share/licenses/${finalAttrs.pname}"
    install -Dm644 data/license.txt -t "$out/share/licenses/${finalAttrs.pname}"

    makeWrapper "$out/libexec/omega" "$out/bin/omega" \
      --run "if [ -n \"\$XDG_STATE_HOME\" ]; then \
          stateRoot=\"\$XDG_STATE_HOME\"; \
        elif [ -n \"\$HOME\" ]; then \
          stateRoot=\"\$HOME/.local/state\"; \
        else \
          stateRoot=\"/tmp\"; \
        fi; \
        stateDir=\"\$stateRoot/${finalAttrs.pname}\"; \
        mkdir -p \"\$stateDir\"; \
        if [ ! -e \"\$stateDir/data\" ]; then \
          ln -s \"$out/share/${finalAttrs.pname}/data\" \"\$stateDir/data\"; \
        fi; \
        for f in omega.hi omega.log; do \
          if [ ! -e \"\$stateDir/\$f\" ] && [ -e \"$out/share/${finalAttrs.pname}/data/\$f\" ]; then \
            cp -n \"$out/share/${finalAttrs.pname}/data/\$f\" \"\$stateDir/\$f\"; \
          fi; \
        done; \
        cd \"\$stateDir\""

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Text-based roguelike game (OmegaRPG fork)";
    homepage = "https://github.com/cwc/OmegaRPG";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "omega";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
