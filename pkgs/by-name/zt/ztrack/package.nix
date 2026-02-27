{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ztrack";
  version = "1.0";

  src = fetchurl {
    url = "mirror://ibiblioPubLinux/games/arcade/ztrack-${finalAttrs.version}.tar.gz";
    hash = "sha256-imHR11uOcZnwEc/GyhEtMYv/SHbP/PAyQYO+mZN3OZk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
  ];

  buildInputs = [
    ncurses
  ];

  NIX_CFLAGS_COMPILE = [
    "-O2"
    "-Wall"
    "-DHAVE_RANDOM"
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CFLAGS="
    "LIBS=-lncurses"
    "LIBS+=-ltinfo"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ztrack -t "$out/bin"
    installManPage ztrack.6
    install -Dm644 README -t "$out/share/doc/${finalAttrs.pname}"

    runHook postInstall
  '';

  meta = {
    description = "Curses-based pseudo-3D driving game";
    homepage = "https://ibiblio.org/pub/linux/games/arcade/ztrack-1.0.tar.gz";
    # README declares public domain.
    license = lib.licenses.publicDomain;
    mainProgram = "ztrack";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
