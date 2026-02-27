{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
  gettext,
  installShellFiles,
}:

python3Packages.buildPythonApplication rec {
  pname = "bambam";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "porridge";
    repo = "bambam";
    rev = "v${version}";
    hash = "sha256-JBcjZAsWvt3MsJBhn01qftX6hJwxW5xoiKNJlj6tIvc=";
  };

  strictDeps = true;

  # No sdist / pyproject; upstream is essentially a single script plus data.
  format = "other";

  nativeBuildInputs = [
    gettext
    installShellFiles
  ];

  propagatedBuildInputs = with python3Packages; [
    pygame
    pyyaml
  ];

  dontBuild = true;

  postPatch = ''
    patchShebangs bambam.py
    substituteInPlace bambam.desktop --replace-fail "/usr/games/bambam" "bambam"
    substituteInPlace bambam-session.desktop --replace-fail "/usr/games/bambam" "bambam"
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    python bambam.py --help | grep -Fq "Keyboard mashing and doodling game for babies and toddlers."

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 bambam.py "$out/bin/bambam"

    install -d "$out/share/bambam"
    cp -a data extensions "$out/share/bambam/"

    install -Dm644 bambam.desktop "$out/share/applications/bambam.desktop"
    install -Dm644 bambam-session.desktop "$out/share/xsessions/bambam-session.desktop"

    install -Dm644 icon.gif "$out/share/pixmaps/bambam.gif"
    install -Dm644 README.md COPYING EXTENSIONS.md CODE_OF_CONDUCT.md -t "$out/share/doc/${pname}"

    installManPage bambam.6

    for f in bambam.*.6; do
      lang="''${f#bambam.}"
      lang="''${lang%.6}"
      install -Dm644 "$f" "$out/share/man/$lang/man6/bambam.6"
    done

    for po in po/*.po; do
      lang="''${po#po/}"
      lang="''${lang%.po}"
      install -d "$out/share/locale/$lang/LC_MESSAGES"
      msgfmt -o "$out/share/locale/$lang/LC_MESSAGES/bambam.mo" "$po"
    done

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Keyboard mashing and doodling game for babies and toddlers";
    homepage = "https://github.com/porridge/bambam";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "bambam";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
