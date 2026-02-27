{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "motti";
  version = "3.1.1";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchurl {
    url = "mirror://gnu/motti/motti-${finalAttrs.version}.tar.gz";
    hash = "sha256-Yy2ahNOy4+7kydkZnWbUJXZRbqbCkQWMAYMK4vt95Ck=";
  };

  strictDeps = true;

  meta = {
    description = "Multiplayer strategy game where players capture a city by occupying key locations";
    homepage = "https://www.gnu.org/software/motti/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "motti";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };

  postInstall = ''
    install -d "$out/bin"
    ln -s ../bin/games/motti "$out/bin/motti"
    ln -s ../bin/games/testmotti "$out/bin/testmotti"

    moveToOutput include "$dev"
    moveToOutput lib "$dev"

    install -Dm644 AUTHORS ChangeLog NEWS README documentation/motti.texi -t "$out/share/doc/${finalAttrs.pname}"
    install -Dm644 COPYING -t "$out/share/licenses/${finalAttrs.pname}"
  '';
})
