{
  lib,
  stdenv,
  fetchgit,
  cmake,
  gnumake,
  nix-update-script,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "moonlight-common-c";
  version = "0-unstable-2026-01-05";

  src = fetchgit {
    url = "https://github.com/moonlight-stream/moonlight-common-c";
    rev = "3a377e7d7be7776d68a57828ae22283144285f90";
    hash = "sha256-YsJHXkQYuEPk84l+iB3au7EPqMfYCtntsJRwfYzpr2A=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    gnumake
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  # Upstream doesn't provide install rules.
  dontUseCmakeInstall = true;

  postPatch = ''
    cat > nixpkgs-prelude.cmake <<'EOF'
    enable_language(CXX)
    include(CheckCXXSourceCompiles)
    EOF
  '';

  preConfigure = ''
    cmakeFlagsArray+=("-DCMAKE_PROJECT_INCLUDE=$PWD/nixpkgs-prelude.cmake")
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 ../src/*.h -t "$dev/include/moonlight-common-c"

    install -Dm755 libmoonlight-common-c${stdenv.hostPlatform.extensions.sharedLibrary} -t "$out/lib"

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 "$src/README.md" -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 "$src/LICENSE.txt" -t "$out/share/licenses/${finalAttrs.pname}"
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Common C library used by Moonlight (GameStream) clients";
    homepage = "https://github.com/moonlight-stream/moonlight-common-c";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
