{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "maggot";
  version = "0-unstable-2014-03-24";

  src = fetchFromGitHub {
    owner = "gciruelos";
    repo = "maggot";
    rev = "f73ad0fe70b7f13208610bcb148cacd6817488db";
    hash = "sha256-IW58b91C2boF6lvYlINgBDxoX5c5sjb5xAFckFGuv7o=";
  };

  strictDeps = true;

  sourceRoot = "source/src";

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];

  NIX_CFLAGS_COMPILE = [ "-D_POSIX_C_SOURCE=200809L" ];

  installPhase = ''
    runHook preInstall

    install -Dm755 maggot -t $out/bin

    install -Dm644 "$src/README.md" "$src/LICENSE.md" -t "$out/share/doc/${finalAttrs.pname}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Simple snake game for the terminal";
    homepage = "https://github.com/gciruelos/maggot";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "maggot";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
