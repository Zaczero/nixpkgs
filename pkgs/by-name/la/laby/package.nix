{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  gnumake,
  librsvg,
  ncurses,
  nix-update-script,
  ocamlPackages,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "laby";
  version = "laby-0.7.0";

  src = fetchFromGitHub {
    owner = "sgimenez";
    repo = "laby";
    tag = "laby-${finalAttrs.version}";
    hash = "sha256-y0ibVDz6lq0Xai8H5Nwsk7N5nowcaBjQWulhKFl31vg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    desktop-file-utils
    gnumake
    ncurses
    ocamlPackages.ocaml
    ocamlPackages.findlib
    ocamlPackages.ocamlbuild
    wrapGAppsHook3
  ];

  buildInputs = [
    ocamlPackages.lablgtk3
    ocamlPackages.lablgtk3-sourceview3
    librsvg
  ];

  postPatch = ''
    patchShebangs .
  '';

  buildPhase = ''
    runHook preBuild

    make

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkPhase = ''
    runHook preCheck

    ./build --help | grep -Fq "usage:"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    make install PREFIX="$out"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 AUTHORS COPYRIGHT TRANSLATION gpl-3.0.txt -t $out/share/doc/laby
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Learn programming by guiding ants through mazes";
    homepage = "https://sgimenez.github.io/laby/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "laby";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
