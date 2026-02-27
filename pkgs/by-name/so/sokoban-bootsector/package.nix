{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  nasm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sokoban-bootsector";
  version = "1.0";

  src = fetchurl {
    url = "https://ish.works/bootsector/sokoban.asm";
    hash = "sha256-EN+AW4oKUPiHyqV9GQxRG2VqmAr843gty+tKaLh5lGY=";
  };

  strictDeps = true;

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    nasm
  ];

  buildPhase = ''
    runHook preBuild

    nasm -f bin -o sokoban.fdd "$src"
    dd if=sokoban.fdd of=sokoban.bin bs=512 count=1 status=none

    runHook postBuild
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    test "$(wc -c < sokoban.fdd | tr -d ' \n')" = 1474560
    test "$(wc -c < sokoban.bin | tr -d ' \n')" = 512
    test "$(od -An -t x1 -j 510 -N 2 sokoban.bin | tr -d ' \n')" = 55aa

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 "$src" -T "$out/share/${finalAttrs.pname}/sokoban.asm"
    install -Dm644 sokoban.fdd -T "$out/share/${finalAttrs.pname}/sokoban.fdd"
    install -Dm644 sokoban.bin -T "$out/share/${finalAttrs.pname}/sokoban.bin"

    makeWrapper ${stdenv.shell} "$out/bin/sokoban-bootsector" \
      --run "if ! command -v qemu-system-i386 >/dev/null; then echo 'qemu-system-i386 not found in PATH (install qemu to run this game)' >&2; exit 127; fi" \
      --add-flags "-c" \
      --add-flags "exec qemu-system-i386 -fda $out/share/${finalAttrs.pname}/sokoban.fdd"

    runHook postInstall
  '';

  meta = {
    description = "Sokoban implemented as a 512-byte x86 boot sector game";
    homepage = "https://ish.works/bootsector/bootsector.html";
    license = lib.licenses.publicDomain;
    mainProgram = "sokoban-bootsector";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
