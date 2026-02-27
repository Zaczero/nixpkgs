{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mafia-werewolf";
  version = "0-unstable-2019-12-20";

  src = fetchFromGitHub {
    owner = "servusDei2018";
    repo = "Mafia-Werewolf";
    rev = "aef38f878cef9ba000ece227243badbcf83d75f2";
    hash = "sha256-8WL1xaNSjzxa9NpIugcUZQteh3efND21emZaL7cOGMY=";
  };

  strictDeps = true;

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  nativeBuildInputs = [
    makeWrapper
  ];

  nativeCheckInputs = [
    python3
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck
    python3 -m py_compile Mafia.py player.py
    runHook postCheck
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 Mafia.py player.py -t "$out/share/${finalAttrs.pname}"
    install -Dm644 LICENSE README.md -t "$out/share/doc/${finalAttrs.pname}"
    makeWrapper ${python3}/bin/python3 "$out/bin/mafia-werewolf" \
      --add-flags "$out/share/${finalAttrs.pname}/Mafia.py"

    runHook postInstall
  '';

  meta = {
    description = "Terminal-based multiplayer Mafia/Werewolf clone with AI";
    homepage = "https://github.com/servusDei2018/Mafia-Werewolf";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "mafia-werewolf";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
