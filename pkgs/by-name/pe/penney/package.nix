{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "penney";
  version = "0.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "sepandhaghighi";
    repo = "penney";
    rev = "0878e3395c6b2f42a1bda85b9fe2d92bd3427139";
    hash = "sha256-jcNHjNViUqybQT3NVjKgPDBHBIGPuE1JWeTXiLf+xYs=";
  };

  strictDeps = true;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    art
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "penney"
  ];

  postInstall = ''
    install -Dm644 "$src/README.md" "$out/share/doc/$pname/README.md"
    install -Dm644 "$src/CHANGELOG.md" "$out/share/doc/$pname/CHANGELOG.md"
    install -Dm444 "$src/LICENSE" "$out/share/licenses/$pname/LICENSE"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Penney's game simulation and CLI";
    homepage = "https://github.com/sepandhaghighi/penney";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "penney";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
