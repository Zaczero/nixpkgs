{
  lib,
  stdenv,
  fetchgit,
  python3Packages,
  stockfish,
  makeWrapper,
  nix-update-script,
}:

python3Packages.buildPythonApplication {
  pname = "chs";
  version = "3.0.0";

  pyproject = true;
  build-system = with python3Packages; [ setuptools ];

  src = fetchgit {
    url = "https://github.com/nickzuber/chs";
    rev = "f9c7b1b476c4ea420a4e47d595e49f1e065de8a7";
    hash = "sha256-ak9fkzn4T/h/SO1Y7kR/CHA7ot+ZLIT48i44phhYG7o=";
  };

  strictDeps = true;

  postPatch = ''
    # Drop bundled engine binaries; use the packaged `stockfish` instead.
    rm \
      chs/engine/stockfish_10_x64_linux \
      chs/engine/stockfish_10_x64_mac \
      chs/engine/stockfish_10_x64_windows.exe \
      chs/engine/stockfish_13_x64_mac
    substituteInPlace chs/engine/stockfish.py \
      --replace-fail "engine_path = 'stockfish_10_x64_linux'" "engine_path = 'stockfish'" \
      --replace-fail "engine_path = 'stockfish_10_x64_windows.exe'" "engine_path = 'stockfish'" \
      --replace-fail "engine_path = 'stockfish_13_x64_mac'" "engine_path = 'stockfish'" \
      --replace-fail "os.path.join(file_path, engine_path)" "engine_path"
  '';

  nativeBuildInputs = [
    makeWrapper
    python3Packages.pythonRelaxDepsHook
  ];

  propagatedBuildInputs = [
    python3Packages.chess
    python3Packages.editdistance
  ];

  pythonRelaxDeps = [
    "python-chess"
  ];

  dontCheckRuntimeDeps = true;

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck
    python -m unittest discover -s tests
    runHook postCheck
  '';

  postInstall = ''
    install -Dm644 README.md LICENSE -t "$out/share/doc/chs"
  '';

  postFixup = ''
    wrapProgram $out/bin/chs \
      --prefix PATH : ${lib.makeBinPath [ stockfish ]}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Play chess against the Stockfish engine in your terminal";
    homepage = "https://github.com/nickzuber/chs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "chs";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
