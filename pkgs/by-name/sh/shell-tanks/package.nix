{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  bash,
  bc,
  coreutils,
  findutils,
  gawk,
  gnugrep,
  gnused,
  netcat-openbsd,
  ncurses,
  util-linux,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "shell-tanks";
  version = "0-unstable-2016-06-19";

  src = fetchFromGitHub {
    owner = "annacrombie";
    repo = "shell-tanks";
    rev = "defad7e7107ea9a35fa41c8734350e7bcb20f51a";
    hash = "sha256-eY8YmbbzFGKycbdzjI+uqGP3yG75oidSbz4cOaHlFYw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -d "$out/share/${finalAttrs.pname}"
    cp -a . "$out/share/${finalAttrs.pname}"
    rm "$out/share/${finalAttrs.pname}/LICENSE" "$out/share/${finalAttrs.pname}/README.md"

    makeWrapper ${bash}/bin/bash "$out/bin/${finalAttrs.pname}" \
      --set SHELL ${bash}/bin/bash \
      --prefix PATH : ${
        lib.makeBinPath [
          bc
          coreutils
          findutils
          gawk
          gnugrep
          gnused
          netcat-openbsd
          ncurses
          util-linux
        ]
      } \
      --run "stateDir=\"''${XDG_STATE_HOME:-$HOME/.local/state}/${finalAttrs.pname}\"" \
      --run "mkdir -p \"$stateDir\"" \
      --run "if [ ! -e \"$stateDir/bin/run.sh\" ]; then cp -R \"$out/share/${finalAttrs.pname}/.\" \"$stateDir/\"; fi" \
      --chdir '$stateDir' \
      --add-flags './bin/run.sh'

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 LICENSE -t $out/share/licenses/${finalAttrs.pname}
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "ASCII artillery game implemented in Bash";
    homepage = "https://github.com/annacrombie/shell-tanks";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "shell-tanks";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
