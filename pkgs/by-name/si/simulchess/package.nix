{
  lib,
  fetchurl,
  python2,
  python2Packages,
}:

python2Packages.buildPythonApplication rec {
  pname = "simulchess";
  version = "0.1.1";

  src = fetchurl {
    url = "https://mbays.freeshell.org/simulchess/simulchess-${version}.tar.gz";
    hash = "sha256-lw/29nfh3wOOiTfNmYdW8XEOa51zkNgCaJwYBxrda4I=";
  };

  strictDeps = true;

  format = "setuptools";

  propagatedBuildInputs = [
    python2
  ];

  pythonImportsCheck = [
    "simulchesspkg"
    "simulchesspkg.State"
  ];

  postInstall = ''
    install -Dm644 README RULES -t $out/share/doc/${pname}
  '';

  # This is Python 2-only software. Python 2 is EOL and considered insecure in nixpkgs,
  # so building/running it requires opting into insecure packages.
  meta = {
    description = "Simultaneous move chess (Python/curses)";
    homepage = "https://mbays.freeshell.org/simulchess/";
    license = lib.licenses.gpl2Only;
    mainProgram = "simulchess";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    insecure = true;
  };
}
