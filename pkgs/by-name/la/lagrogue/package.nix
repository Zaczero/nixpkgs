{
  lib,
  stdenv,
  fetchurl,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lagrogue";
  version = "0.1.2";

  src = fetchurl {
    url = "http://mbays.sdf.org/lagrogue/src/lagrogue-${finalAttrs.version}.tar.gz";
    hash = "sha256-d6dozNPA6vun4JmY6ZYEBAVFEQNr6owz5kUJrjosoxI=";
  };

  strictDeps = true;

  buildInputs = [
    ncurses
  ];

  # Fully interactive curses UI with no CLI flags; a reliable non-interactive
  # smoke test is not practical.

  meta = {
    description = "Roguelike about telemetric control and latency (curses UI)";
    homepage = "http://mbays.sdf.org/lagrogue/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "lagrogue";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
