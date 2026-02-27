{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xonitix";
  version = "0-unstable-2021-06-07";

  src = fetchFromGitHub {
    owner = "garu";
    repo = "Xonitix";
    rev = "8d0eba81ff0984d4f1415214c5edb5a8ab1566d0";
    hash = "sha256-pn4WI4u1k9+CoowA+LM6uBvJgRwlYWn8yaosj4HAB6w=";
  };

  strictDeps = true;

  buildPhase = ''
    runHook preBuild

    $CXX -std=c++11 -o xonitix xonitix.cpp

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 xonitix -t "$out/bin"

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
    description = "Action game for the terminal inspired by Xonix";
    homepage = "https://github.com/garu/Xonitix";
    license = lib.licenses.mit;
    mainProgram = "xonitix";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
