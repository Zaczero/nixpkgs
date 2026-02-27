{
  lib,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  python3,
}:

let
  pyPkgs = python3.pkgs;
  pythonPath = pyPkgs.makePythonPath [
    pyPkgs.chess
    pyPkgs.tqdm
  ];
in
pyPkgs.buildPythonApplication rec {
  pname = "sunfish";
  version = "0-unstable-2025-05-17";

  src = fetchFromGitHub {
    owner = "thomasahle";
    repo = "sunfish";
    rev = "bd5ef7b508e8d87a1bb3404b1151f65343964caf";
    hash = "sha256-XJwJGrU0TbtqQrQRQ2x/ZqhsZ+Acp6Nr6cCJfvj4DKI=";
  };

  strictDeps = true;

  format = "other";

  nativeBuildInputs = [
    makeWrapper
  ];

  propagatedBuildInputs = [
    pyPkgs.chess
    pyPkgs.tqdm
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 sunfish.py -t "$out/lib/${pname}"
    install -Dm755 sunfish_nnue.py -t "$out/lib/${pname}"
    cp -a tools "$out/lib/${pname}/"

    makeWrapper ${python3.interpreter} "$out/bin/${pname}" \
      --add-flags "$out/lib/${pname}/sunfish.py" \
      --prefix PYTHONPATH : "${pythonPath}:$out/lib/${pname}"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${pname}
    install -Dm644 LICENSE.md -t $out/share/licenses/${pname}
    cp -a docs $out/share/doc/${pname}/
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    output="$(printf 'uci\nquit\n' | $out/bin/${pname})"
    grep -Fq "uciok" <<<"$output"

    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Simple chess engine written in Python with a UCI interface";
    homepage = "https://github.com/thomasahle/sunfish";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "sunfish";
  };
}
