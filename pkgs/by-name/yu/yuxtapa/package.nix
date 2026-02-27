{
  lib,
  stdenv,
  fetchFromGitHub,
  ncurses,
  zlib,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yuxtapa";
  version = "0-unstable-2018-10-24";

  src = fetchFromGitHub {
    owner = "lotuskip";
    repo = "yuxtapa";
    rev = "6fcf7dc23d69e52569cf6381701344ecdf09519b";
    hash = "sha256-tbXfQsVuqgTakCUk/3rxJXAzO4FvvqJURSHniJ/+gfw=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
    zlib
  ];

  buildPhase = ''
    runHook preBuild

    make all \
      CXX="${stdenv.cc.targetPrefix}c++" \
      CONFIG_FLAGS="-O2" \
      EXTRA_FLAGS="" \
      LDLIBS_CL="-lncursesw -lz" \
      LDLIBS_SV="-lz"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 yuxtapa_cl -t "$out/bin"
    install -Dm755 yuxtapa_sv -t "$out/bin"

    # Runtime data / templates.
    install -d "$out/share/yuxtapa"
    cp -a tmplates "$out/share/yuxtapa"

    # End-user manual (HTML).
    install -d "$out/share/doc/${finalAttrs.pname}"
    cp -a manual "$out/share/doc/${finalAttrs.pname}/"

    install -Dm644 README -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 LICENSE -t "$out/share/licenses/${finalAttrs.pname}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Multiplayer roguelike-inspired team game (client and server)";
    homepage = "https://github.com/lotuskip/yuxtapa";
    license = lib.licenses.mit;
    mainProgram = "yuxtapa_cl";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
