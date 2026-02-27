{
  lib,
  python311Packages,
  fetchFromGitHub,
  nix-update-script,
}:

let
  pname = "redeal";
  version = "0.2";
in
python311Packages.buildPythonApplication {
  inherit pname version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "anntzer";
    repo = "redeal";
    rev = "abed245e9bc5f3dc789c55f0ba161afebcc67fdf";
    hash = "sha256-UgNQzTgZGjBAkRssFcbIK93nLD20oWhuF1Lf6t9sf6c=";
  };

  strictDeps = true;

  build-system = with python311Packages; [ setuptools ];

  dependencies = with python311Packages; [
    colorama
    tkinter
  ];

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${pname}
    install -Dm644 LICENSE.txt GPL-3.0.txt -t $out/share/licenses/${pname}
    cp -a examples $out/share/doc/${pname}/
  '';

  pythonImportsCheck = [ "redeal" ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/redeal --help >/dev/null

    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Reimplementation of Thomas Andrews' Deal in Python";
    homepage = "https://github.com/anntzer/redeal";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "redeal";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.all;
  };
}
