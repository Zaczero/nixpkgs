{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "othello";
  version = "0.03";

  src = fetchurl {
    url = "https://web.archive.org/web/20071107144115id_/http://david.weekly.org/othello/othello-0.03.tar.gz";
    hash = "sha256-r6KikWJ9krRKbdftfOgXr3SvjZ7cXhafWRCkzYSvGYA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
  ];

  dontConfigure = true;

  preBuild = ''
    cat > config.h <<EOF
    #define STDC_HEADERS 1
    #define PACKAGE "${finalAttrs.pname}"
    #define VERSION "${finalAttrs.version}"
    EOF
  '';

  buildPhase = ''
    runHook preBuild

    $CC $CPPFLAGS $CFLAGS -o othello othello.c $LDFLAGS -lm

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    output="$(printf 'n\n' | ./othello)"
    grep -Fq "Would you like to play a game of Othello?" <<<"$output"
    grep -Fq "Okay, no more Othello..." <<<"$output"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 othello -t "$out/bin"
    installManPage othello.6
    install -Dm644 ChangeLog NEWS README -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 COPYING -t "$out/share/licenses/${finalAttrs.pname}"

    runHook postInstall
  '';

  meta = {
    description = "Simple Othello/Reversi game against the computer";
    homepage = "https://web.archive.org/web/20130607084226/http://david.weekly.org/othello/index.php3";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "othello";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
