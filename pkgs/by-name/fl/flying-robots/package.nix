{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "flying-robots";
  version = "0-unstable-2021-12-21";

  pyproject = true;

  src = fetchFromGitHub {
    owner = "bunburya";
    repo = "flying-robots";
    rev = "6cb61913d07c6200f036ea05b7b0ca952aad5eb9";
    hash = "sha256-3s38VLIhVMr/yOB9h5SIiqArVKluOzVB1NmFndTjw7M=";
  };

  strictDeps = true;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    tkinter
  ];

  postInstall = ''
    install -Dm644 README.md -t "$out/share/doc/flying-robots"
  '';

  doCheck = false;
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    export HOME="$(mktemp -d)"
    export XDG_CONFIG_HOME="$HOME/.config"

    python -c "import flying_robots"
    python scripts/flying-robots --help | grep -Fq "Options:"

    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Three-dimensional clone of the classic BSD Robots game";
    homepage = "https://github.com/bunburya/flying-robots";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "flying-robots";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
