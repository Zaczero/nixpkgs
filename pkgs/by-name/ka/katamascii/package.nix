{
  lib,
  stdenv,
  fetchFromGitHub,
  gnumake,
  makeWrapper,
  nix-update-script,
  perl,
  pkg-config,
  chipmunk,
  glib,
  libcaca,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "katamascii";
  version = "0-unstable-2022-04-25";

  src = fetchFromGitHub {
    owner = "taviso";
    repo = "katamascii";
    rev = "fb88bfe095a0d1550825719dd85c57a65677f7ec";
    hash = "sha256-W6XbyQwNhWehxery55JM8+GDg5Z44fBPpbsRzTRG/YE=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gnumake
    makeWrapper
    perl
    pkg-config
  ];

  buildInputs = [
    chipmunk
    glib
    libcaca
    ncurses
  ];

  # Upstream Makefile defaults to debugging flags and hardcodes `/usr/include/chipmunk`.
  # Override via make variables to keep sources untouched and to compile against Nix deps.
  buildPhase = ''
    runHook preBuild

    make \
      CC=$CC \
      CPPFLAGS="-DNDEBUG -I${chipmunk}/include -I${chipmunk}/include/chipmunk" \
      CFLAGS="$NIX_CFLAGS_COMPILE -O2 -Wno-error=incompatible-pointer-types -Wno-incompatible-pointer-types $($PKG_CONFIG --cflags glib-2.0)" \
      LDLIBS="-lm -lchipmunk -lcaca -lncursesw $($PKG_CONFIG --libs glib-2.0)"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 katamascii -t "$out/libexec"
    install -Dm644 art/* -t "$out/share/katamascii/art"
    install -Dm644 tiles/* -t "$out/share/katamascii/tiles"

    install -Dm644 -t $out/share/doc/katamascii README.md LICENSE

    makeWrapper "$out/libexec/katamascii" "$out/bin/katamascii" \
      --chdir "$out/share/katamascii"

    runHook postInstall
  '';

  # Inherently interactive ncurses game and provides no reliable non-interactive flag.

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Terminal puzzle game prototype inspired by Katamari Damacy";
    homepage = "https://github.com/taviso/katamascii";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "katamascii";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
