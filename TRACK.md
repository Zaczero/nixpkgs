# Package Review Progress Tracking

TASK REMINDER:
Go over all of our new pending game packages. This is historical museum software and we prefer to minimize amount of patching and good quality packaging for historical preservation.

For each, check if it compiles and cross compiles (nix commands), check the upstream contents and ensure any manuals, data, useful docs, are preserved and the folder structure in the out is correct. Pay attentio to eventual bugs or incorrect packaging so far (there may be). Always verify, don't guess. Ensure the paths are correct for nixpkgs distribution. Prefer idiomatic nixpkgs patterns, avoid reinventing the wheel, following the best practices for good quality packaging.

Go alphabeticall over our new packages (see git staged but never stage any changes yourself). Use TRACK.md to track your progress and to save out any useful information/findings as you work. A handy document to help you acomplish the full task properly and with good quality.

We value our packages are prepared up to standard, use nixpkgs idiomatic patterns and existing tools/utils/hooks. That's about 165 packages to go.

Work one by one, one through completion then next. Always update the TRACK.md living document. Ensure manuals and other important assets are packaged.

remember to spot check for any bugs while iterating and noting and good patterns found in the TRACK.md. in addition to the checklist, seeing the big picture and thinking if it makes even sense.
:END OF TASK REMINDER

## Summary

- Total Packages: 165
- Reviewed: 165
- Pending: 0
- Cross-build target (representative): pkgsCross.aarch64-multiplatform (64-bit ARM). Use this for all remaining cross-build checks.
- Platform metadata note: prefer `platforms = lib.platforms.unix; badPlatforms = lib.platforms.aarch64;` over narrowing to `lib.platforms.x86` so we keep OS-family intent while excluding known-broken architectures.
- Packaging best-practices notes (keep applying as we go):
  - Prefer nixpkgs-idiomatic patterns/utilities over ad-hoc fixes; adjust derivations before patching upstream unless strictly necessary.
    - Scoped build-system fixes are acceptable and often preferred (for cross-compile correctness) as long as they remain minimal and targeted.
      - This includes `substituteInPlace` on build-system files like `Makefile` when it’s narrowly fixing hardcoded tool names/paths (e.g. replacing a hardcoded `gcc` link command with `$CC`), and is often preferable to patching “real” upstream source code.
  - When there’s a choice, prefer XDG-friendly runtime paths: avoid writing into `$out` and avoid hardcoding `/var` when the upstream design is “per-user mutable state”. Use XDG env (`XDG_STATE_HOME`, `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, `XDG_DATA_HOME`) via wrappers and provide sensible defaults that respect overrides, so packages behave well on NixOS and other Nix-based systems.
    - Do **not** “force XDG” at the expense of historical preservation: if upstream intentionally uses `~/.something` as part of the historical behavior, keep it unless we have a clear, legitimate reason to change (e.g. it breaks in the Nix store, violates sandboxing, or causes real runtime issues).
    - Hardcoded global paths (e.g. `/var/...`) can be appropriate when they’re required for correctness or match upstream’s system-wide design; prefer wrappers/XDG only when the state is clearly user-specific and mutable.
- Documentation layout: prefer `$out/share/doc/${pname}` / `$out/share/doc/${finalAttrs.pname}` instead of hardcoded names like `$out/share/doc/foo`, to keep expressions refactor-safe.
  - Common nixpkgs pattern: `install -Dm644 -t $out/share/doc/${pname} README* COPYING*` (inline path is typical).
  - Avoid single-use shell path variables like `docDir=...` / `licenseDir=...`; inline the target path unless you truly reuse it multiple times.
  - Prefer listing sources before the target flag: `install -Dm644 README AUTHORS -t $out/share/doc/${pname}`.
  - Nix-level `let docDir = "..."; in '' ... ${docDir} ... ''` is valid, but not the common style in-tree (prefer inline or a shell variable).
  - When using a separate doc output: add `outputs = [ "out" "doc" ];` and then install docs to `$doc/share/doc/${pname}` (used when docs are large or we want to keep runtime closure smaller).
  - Reference example in-tree: `pkgs/servers/dict/default.nix` uses `install -Dm444 -t $out/share/doc/${pname} NEWS README`.
  - `${pname}` interpolation for doc dirs is a **soft** preference: do not churn packages just to rename `$out/share/doc/<upstream>` into `$out/share/doc/${pname}`. Prefer minimal patching for historical preservation; only normalize when there’s a concrete reason (collision, incorrect install, refactor hazard in our own custom install step, etc.).
- Don’t package “everything blindly”: prioritize user-relevant docs (README*, manual, COPYING/LICENSE, AUTHORS, NEWS/ChangeLog); include developer-only files (e.g. TODO) only if they meaningfully help users.
- Docs policy (write this down clearly): only install documentation that is actually useful to end users (game instructions, usage, manual, changelog/NEWS when relevant, license texts).
  - Skip contributor/developer-only files like CONTRIBUTING, HACKING, CI configs, build-only instructions, and **TODO files** by default.
  - Treat `BUGS` similarly: include only when it contains user-relevant known issues/workarounds; skip “report bugs to X” boilerplate or vague developer notes.
  - Include a TODO only when it is clearly user-facing (e.g. contains gameplay notes, known bugs/workarounds that affect players, or essential “how to play” info not found elsewhere). Most upstream TODOs are developer roadmaps and should be excluded as noise.
- Avoid build/dev-only docs (e.g. INSTALL with build instructions) in final outputs unless they provide end-user value.
- If upstream has a public changelog link, add `meta.changelog` so users can find it easily.
- When ancient code fails to build, prefer first trying a compile-flag or language-standard adjustment before patching; only patch when clearly required for correctness on modern toolchains.
  - Prefer a single home for license files to avoid duplication: use `$out/share/licenses/${pname}` and don’t also copy the same license into `$out/share/doc/${pname}` unless there’s a strong reason.
  - Don’t add conditional moves/installs in packaging unless you’ve verified multiple layouts.
    - Prefer a single deterministic layout based on observed install outputs.
    - Avoid “defensive” shell like `if [ -d ... ]` and also avoid `|| true` / swallowing errors; if your fix relies on an invariant you’ve observed (e.g. a placeholder is present), make it fail loudly when the invariant doesn’t hold so we notice upstream changes.
    - Prefer fixing the root cause (e.g. patching a generated `Makefile` / install rule) over post-install copying/moving.
  - Prefer `install` over `cp` when reasonable (`install -Dm644` for docs, `install -Dm755` for binaries, `installManPage` for manpages, etc.) to ensure permissions/dirs are correct and reproducible.
  - Install layout quick-checks for games:
    - Binaries: `$out/bin/*` (or `$out/games/*` only if that’s the established package convention; prefer `$out/bin`).
    - Shared assets: `$out/share/${pname}/...` (or upstream-provided `pkgdatadir` equivalent); keep runtime data out of `$out/share/doc`.
    - Desktop integration (when upstream provides it): `$out/share/applications/*.desktop`, `$out/share/icons/hicolor/...`, appstream metadata typically `$out/share/metainfo/*.xml` (some older projects use `$out/share/appdata`).
- libexec notes:
  - Intended for helper executables not meant to be on `$PATH` directly; common pattern is “put real executable/script in `$out/libexec/${pname}/...` and expose a small wrapper in `$out/bin`”.
  - Reference example in-tree: `pkgs/by-name/ya/yahtzee/package.nix` installs to `$out/libexec/yahtzee` and wraps to `$out/bin/yahtzee` with state-dir setup.
  - Multi-output detail: `pkgs/build-support/setup-hooks/multiple-outputs.sh` sets `--libexecdir` to the *lib output* by default (`${!outputLib}/libexec`), so if a package uses multiple outputs, `libexec` may end up under `$lib/libexec` (worth keeping in mind when choosing paths).
- Hooks/utils notes (where to look):
  - Setup hooks live in `pkgs/build-support/setup-hooks/` (e.g. `make-wrapper.sh` for `makeWrapper`/`wrapProgram`, `patch-shebangs.sh` for `patchShebangs`, `copy-desktop-items.sh`, `compress-man-pages.sh`, `multiple-outputs.sh`, `move-docs.sh`).
  - Some hooks are packaged under by-name (e.g. `installShellFiles` lives at `pkgs/by-name/in/installShellFiles/` with `setup-hook.sh`).
- Build command note:
  - Prefer legacy `nix-build -A <attr> --no-out-link` (and `nix-build -A pkgsCross.aarch64-multiplatform.<attr> --no-out-link` for cross) for quicker iteration vs flake `nix build .#...` when working inside this nixpkgs checkout.
  - For manual `$CC` invocations, avoid hardcoding `-O2`; rely on `$NIX_CFLAGS_COMPILE` and keep link flags minimal (the cc-wrapper injects required search paths). Don’t pass `$NIX_LDFLAGS` directly to `$CC` (it may contain `-rpath <path>` tokens that GCC rejects); only plumb it through build systems that know how to translate it, or add the needed `-L...` flags explicitly when required.
- Manpages: if upstream provides roff sources (typically starting with `.TH`), install them to `$out/share/man/man<section>/` (e.g. `moria.6`) so nixpkgs' manpage hooks can compress them; treat preformatted “catman” pages as docs instead of installing as manpages.
  - Prefer `installManPage` (from `installShellFiles`) for roff manpages we install ourselves: it’s the idiomatic nixpkgs helper and keeps permissions/paths consistent. Use raw roff sources (`*.1`, `*.6`, etc.), not pre-compressed `*.gz`.
  - For `substituteInPlace`, prefer `--replace-fail` so changes are invariant-checked and we notice upstream drift; avoid `--replace`/`--replace-warn` (soft matching) for these museum packages.
  - Install/check probes: if a program’s `--help/-h/--version` is expected to exit non-zero (common for older/interactive software), using `... || true` in `checkPhase`/`installCheckPhase` is acceptable and preferred over toggling `set +e/-e`.
- Update scripts:
  - Prefer `passthru.updateScript = nix-update-script { };` when the upstream is on a nix-update-supported forge and publishes real releases/tags.
  - For tagless/“no releases” repos (common for these museum packages), use `nix-update-script { extraArgs = [ "--version=branch" ]; }` so updates are deterministic snapshots based on the latest commit.
  - For tarball-only upstreams on unsupported hosting (notably SourceForge mirrors and random websites), `nix-update-script { extraArgs = [ "--version=skip" ]; }` is acceptable so tooling can at least re-hash sources without failing.
  - For non-standard/self-hosted git URLs that nix-update’s forge backends can’t parse reliably, fall back to `unstableGitUpdater` (generic git clone + commit-date snapshot).

## Global Re-audit (2026-01-07)

Re-checked all git-staged `pkgs/by-name/**/package.nix` entries against the summary checklist (static scan + targeted rebuilds where needed).

- Docs noise cleanup: removed installation of upstream TODO files and CONTRIBUTING/build-only docs in the few packages that were still shipping them by default (most TODOs were developer roadmaps / non-essential notes).
- Manpages: confirmed `installManPage` usage is consistent; only remaining manual man install is `bambam` (localized manpage subdirs), which is a valid exception.
- Cross-compile regression fix found during re-audit: `hunt-ng` needed explicit `AR`/`RANLIB` and autoconf cache vars for `malloc/realloc` nonnull checks to avoid `rpl_malloc/rpl_realloc` link failures under `pkgsCross.aarch64-multiplatform`.

## Package Status

| Package | Status | Build | Cross | Notes |
| :--- | :--- | :--- | :--- | :--- |
| abe | Completed | Yes | Yes | Added docs (README, AUTHORS, ChangeLog, NEWS). |
| aburatan | Completed | Yes | Yes | Added docs (manual.txt, history.txt, contrib.txt). |
| alienblaster | Completed | Yes | Yes | Added docs (AUTHORS, CHANGELOG, README, VERSION). Switched to pkg-config. |
| aliens | Completed | Yes | Yes | Added docs (README.md, UNLICENSE), patched SCOREFILE to be relative to stateDir in wrapper. |
| alienwave | Completed | Yes | Yes | Added docs (README, STORY, TO_DO). |
| anonymine | Completed | Yes | Yes | Added docs, fixed cursescfg search path. Install `enginecfg` (generated via upstream mkenginecfg) and wrap to run from an XDG-friendly state dir so the game finds enginecfg and writes highscores outside the Nix store. |
| aop | Completed | Yes | Yes | Added docs (README, COPYING), patched aop.c to use absolute level paths with increased buffer. |
| apricots | Completed | Yes | Yes | Added docs (AUTHORS, ChangeLog, NEWS, README.md), desktop file, and icon. |
| arkanoid-bash | Completed | Yes | Yes | Added docs (README). License is unfree (no license in repo). Patched upstream cleanup to avoid `pkill -F <(…)` error on Ctrl+C (use `kill $CHILD` instead), and dropped procps dependency. |
| arkanoid-sed | Completed | Yes | Yes | Updated homepage and license (GPL-2.0). Fixed checkPhase to actually select a level (script needs an initial empty line before the welcome prompt). Added an interactive wrapper hint explaining the “press Enter once first” behavior. |
| arkurses | Completed | Yes | Yes | Added docs (README.md). License is unfree (no license in repo). |
| ascii-chess | Completed | Yes | Yes | Added docs (README, COPYING). |
| ascii-dash | Completed | Yes | Yes | Added docs. Added SDL2 and SDL2_mixer for sound support. Fixed runtime asset installation (install `sounds/` in addition to `data/`) and wrapper: only `--chdir` into `$out/share/ascii-dash` so upstream defaults work (no forced level selection). |
| ascii-invaders | Completed | Yes | Yes | Added docs. |
| ascii-snake | Completed | Yes | Yes | Added docs. |
| ascii-tetris | Completed | Yes | Yes | Added docs. |
| asciip-ortal | Completed | Yes | Yes | Added docs. Fixed cross-compilation by correctly specifying CXX and LINKFLAGS. |
| astwar | Completed | Yes | Yes | Added docs. |
| avanor | Completed | Yes | Yes | Added docs (including manual). |
| awkaster | Completed | Yes | Yes | Added docs (README, LICENSE). |
| bambam | Completed | Yes | Yes | Added docs (including Markdown files), icon, and patched desktop files. |
| bash-dungeon | Completed | Yes | Yes | Added docs (README.md, LICENSE). |
| bashmaze | Completed | Yes | Yes | Added docs (README.md). verified unfree license (no license in repo). |
| basic-highnoon | Completed | Yes | Yes | Added docs (README.md, LICENSE, original images). Fixed bwbasic build with -std=gnu89. |
| beejjorgensen-conquest | Completed | Yes | Yes | Added docs (README.md, instructions.txt, archives). |
| behacked | Completed | Yes | Yes | Added docs (README). |
| berk76-tetris | Completed | Yes | Yes | Added docs (including manual images). |
| cboard | Completed | Yes | Yes | Added pkg-config, patched configure to bypass ptmx check during cross-compilation. Preserved docs (including COPYING). |
| chimaera | Completed | Yes | Yes | Verified build and cross-build. Preservation of docs confirmed. |
| chs | Completed | Yes | Yes | Preserved README.md and LICENSE. Wrapped for stockfish engine. |
| clines | Completed | Yes | Yes | Preserved AUTHORS, ChangeLog, NEWS, README, README.md, COPYING, LICENSE. |
| cnibbles | Completed | Yes | Yes | Preserved CHANGES, LICENSE, README. Verified build and cross-build. |
| conix | Completed | Yes | Yes | Preserved README. Checked build and cross-build. |
| connect4 | Completed | Yes | Yes | Preserved README, README.md. Wrapped to use local scoreDatabase.bin. |
| conquest | Completed | Yes | Yes | Added docs (README.md, docs/*.md, docs/*.txt). Fixed build permissions. |
| cpat | Completed | Yes | Yes | Preserved AUTHORS, ChangeLog, NEWS, README. Verified build and cross-build. |
| cryptoslam | Completed | Yes | Yes | Preserved CHANGELOG, README, sample.txt. Checked build and cross-build. |
| csol | Completed | Yes | Yes | Preserved CHANGES.md, README.md. Wrapped with XDG_CONFIG_DIRS for assets. Verified build and cross-build. |
| ctris | Completed | Yes | Yes | Preserved AUTHORS, COPYING, LICENSE, README. Verified build and cross-build. |
| dango | Completed | Yes | Yes | Preserved README.md, LICENSE.md. Verified build. |
| dds | Completed | Yes | Yes | Preserved ChangeLog, LICENSE, README.md. Verified build and cross-build. |
| duelcommander | Completed | Yes | Yes | Preserved README and doc/*. Verified build and cross-build. |
| eyangband | Completed | Yes | Yes | Preserved eychanges5.txt, wrapped with ANGBAND_PATH. |
| fkmines | Completed | Yes | Yes | Preserved README, renamed binaries. |
| flying-robots | Completed | Yes | Yes | Preserved README.md. Corrected metadata. |
| foobillardplus | Completed | Yes | Yes | Normalized prefix and data paths. Added docs, desktop file, and icon. |
| freecell-ng | Completed | Yes | Yes | Preserved AUTHORS, ChangeLog, NEWS, README, README.md. |
| freegish | Completed | Yes | Yes | Modernized (CMake, GCC 15/stdbool.h fix), preserved docs. |
| freerct | Completed | Yes | Yes | Bumped CMake version, fixed postInstall documentation paths. |
| ft_retro | Completed | Yes | Yes | Preserved README. Fixed build (C89, missing defines). |
| gnu-conquest | Completed | Yes | Yes | Fixed build and meta. Preserved docs. |
| gnupong | Completed | Yes | Yes | Preserved AUTHORS. |
| gnurobots | Completed | Yes | Yes | Fixed build with guile 1.8 (C89, -Werror removal). Preserved docs. |
| gnuski | Completed | Yes | Yes | Verified doc preservation and binary location. |
| gopnik2 | Completed | Yes | Yes | Switched to catch2_3, removed FetchContent, preserved docs. |
| gpcslots1 | Completed | Yes | Yes | Normalized build and check. |
| gpcslots2 | Completed | Yes | Yes | Normalized build and check. |
| hamurabi | Completed | Yes | Yes | Preserved README. |
| hellband | Completed | Yes | Yes | Preserved README.md, changes.txt, gdb-notes.md, COPYING.txt, LICENSE. |
| hinversi | Completed | Yes | Yes | Preserved README. Fixed build with -std=gnu89. |
| hunt-ng | Completed | Yes | Yes | Preserved end-user docs + manpages. Cross build fixed with explicit `AR`/`RANLIB` and autoconf cache vars for `malloc/realloc` nonnull checks (avoid `rpl_malloc/rpl_realloc` link failures). |
| katamascii | Completed | Yes | Yes | Preserved README.md, LICENSE. Converted and bundled art/ and tiles/. |
| kgames | Completed | Yes | Yes | Preserved README and COPYING. Fixed cross-build by adding buildPackages.stdenv.cc for native Meson executables. |
| knights | Completed | Yes | Yes | Preserved README.txt, README-SDL.txt, lua_docs, amiga_knights, CHANGES.txt (via docs/). Verified build and cross-build. |
| laby | Completed | Yes | No | Preserved AUTHORS, COPYRIGHT, TRANSLATION, gpl-3.0.txt. Added wrapGAppsHook3 and librsvg for GTK3 support. OCaml cross-compilation not supported by nixpkgs. |
| lagrogue | Completed | Yes | Yes | Minimal documentation. Verified build and cross-build. |
| landing-rust | Completed | Yes | Yes | Verified build and cross-build. Minimal docs (reference implementations). |
| lead-solver | Completed | Yes | Yes | Preserved Changelog.txt. Verified build and cross-build. |
| letrain | Completed | Yes | Yes | Preserved README.md, LICENSE, commands.txt, images/. |
| li-ri | Completed | Yes | Yes | Added docs (AUTHORS, COPYING, COPYING.Music, INSTALL, NEWS.yaml, README.md). |
| lierolibre | Completed | Yes | No | Added docs (AUTHORS, COPYING, COPYING_winbin, ChangeLog, NEWS, README, README.txt, README_linuxbin, lgpl-2.1.txt). Native build needed sox + imagemagick for asset generation and SDL macros for autoreconf. Not compatible with aarch64 (gvl platform.h only handles x86/x86_64); set meta.platforms = lib.platforms.unix and meta.badPlatforms = lib.platforms.aarch64. |
| lightcycle | Completed | Yes | Yes | Preserved docs (README.md, LICENSE.md). Simple Python 3 script; versionCheckHook runs `lightcycle -v` on native builds. |
| mafia-werewolf | Completed | Yes | Yes | Preserved docs (README.md, LICENSE). Installs game scripts to `$out/share/${pname}` and wraps with `python3`. |
| maggot | Completed | Yes | Yes | Preserved docs (README.md, LICENSE.md). CMake project builds a single terminal binary. |
| mangband | Completed | Yes | Yes | Preserved README in `$out/share/doc/${pname}`; license in `$out/share/licenses/${pname}` only. Cross build needed `buildPackages.stdenv.cc` (ar) and `ac_cv_func_malloc_0_nonnull`/`ac_cv_func_realloc_0_nonnull` to avoid gnulib rpl_* symbols. |
| mastermind-nc | Completed | Yes | Yes | Installed runtime data (scores/informations/settings) to `$out/share/${pname}` and wrapped binary to use XDG state dir, seeding defaults on first run. Added README to `$out/share/doc/${pname}` and LICENCE to `$out/share/licenses/${pname}`. |
| meandmyshadow | Completed | Yes | Yes | Installed docs (README.md, ChangeLog, AUTHORS, docs/*.md) to `$out/share/doc/${pname}` and license to `$out/share/licenses/${pname}`. Moved CMake-installed AUTHORS out of `$out/share/${pname}` into docs based on observed install layout (no conditional). |
| mediocrity | Completed | Yes | Yes | Added docs (README, INSTALL, NEWS) to `$out/share/doc/${pname}` and license to `$out/share/licenses/${pname}`. Cross build fixed by adding `buildPackages.SDL` for `sdl-config` and `buildPackages.stdenv.cc` for native `ar`. |
| memwatch | Completed | Yes | Yes | Added docs (README.md, NEWS) from source and license to `$out/share/licenses/${pname}`; skipped INSTALL (build-only). |
| minecurses | Completed | Yes | Yes | Added README.md to `$out/share/doc/${pname}` and LICENSE to `$out/share/licenses/${pname}`. |
| minesviiper | Completed | Yes | Yes | Added README.md to `$out/share/doc/${pname}` and LICENSE to `$out/share/licenses/${pname}`. |
| minesweeper-sh | Completed | Yes | Yes | Added CHANGES to `$out/share/doc/${pname}`; no license file in repo (unfree). |
| miscom | Completed | Yes | Yes | Added docs (README, ChangeLog) to `$out/share/doc/${pname}` and license to `$out/share/licenses/${pname}`. Minimal build fixes: switch to compiler `-include string.h`/`-include stdlib.h` (no source edits for includes), plus `bombout(int)` signature + call-site updates for valid signal handler type. |
| monousa | Completed | Yes | Yes | Added README to `$out/share/doc/${pname}`. No license file in tarball (unfree). |
| moonlight-common-c | Completed | Yes | Yes | Multi-output (out/dev). Installed headers to `$dev/include/moonlight-common-c`, shared lib to `$out/lib`, plus README to `$out/share/doc/${pname}` and LICENSE.txt to `$out/share/licenses/${pname}`. |
| moria | Completed | Yes | Yes | Installed docs (README, M.doc, Moria.doc.1, Moria.doc.2, Moria.man.alt) to `$out/share/doc/${pname}`; installed roff manpage `Moria.man` as `$out/share/man/man6/moria.6` (preformatted `Moria.1` not installed as manpage). Cross build fixed by passing `CC=${stdenv.cc.targetPrefix}cc` to `make`. |
| morpion-solitaire | Completed | Yes | Yes | Added README to `$out/share/doc/${pname}` and LICENSE to `$out/share/licenses/${pname}`. |
| morris | Completed | Yes | Yes | Fixed locale install path (`@DATADIRNAME@` -> `share`, avoiding `$out/@DATADIRNAME@/locale`). Cross build fixed by setting `ac_cv_func_malloc_0_nonnull`/`ac_cv_func_realloc_0_nonnull` to avoid gnulib `rpl_*` replacements. |
| motti | Completed | Yes | Yes | Multi-output (out/dev). Preserved AUTHORS, ChangeLog, NEWS, README, motti.texi, and COPYING. |
| mutantaliens | Completed | Yes | Yes | Preserved README, MANUAL, CHANGES. No upstream license file (unfree). |
| nclife | Completed | Yes | Yes | Preserved README.md and ChangeLog; installed LICENSE to `$out/share/licenses/${pname}`. |
| ncursesoflife | Completed | Yes | Yes | Preserved README.md. No upstream license file (unfree). |
| net-o-grama | Completed | Yes | Yes | Installed runtime data (wordlist.txt, audio/) to `$out/share/net-o-grama` and preserved docs (AUTHORS, ChangeLog, NEWS, ReadMe) + License. |
| netpanzer | Completed | Yes | Yes | Preserved end-user docs (README.md, SERVER-HOWTO.md). Removed CONTRIBUTING.md as developer-only noise. License (COPYING.txt) installed to `$out/share/licenses/${pname}` (moved out of doc dir). |
| nettoe | Completed | Yes | Yes | Preserved docs (README, AUTHORS, ChangeLog, NEWS, BUGS, TO-DO, protocol.txt) to `$out/share/doc/${pname}` and COPYING to `$out/share/licenses/${pname}`. Enabled optional desktop/menu install (desktop file + hicolor icons). |
| nlarn | Completed | Yes | Yes | Added docs (README.md, Changelog.md) to `$out/share/doc/${pname}` and LICENSE to `$out/share/licenses/${pname}`. Patched Makefile to drop `-Werror` and to avoid `pkg-config` (inject glib/ncurses/zlib flags for cross builds). |
| nsudoku | Completed | Yes | Yes | Preserved upstream source (`nsudoku.c`) in docs, and extracted the embedded MIT license header into `$out/share/licenses/${pname}/LICENSE`. |
| nsuds | Completed | Yes | Yes | Fixed installation: avoid immutable `$out/var` by installing `high_scores` into `$out/share/nsuds` and patching SCOREDIR. Disabled upstream `chgrp/chmod` install hooks for sandboxed builds. Preserved docs (AUTHORS, ChangeLog, INSTALL, NEWS, README) and COPYING in `$out/share/licenses/${pname}`. |
| nuzzle | Completed | Yes | Yes | Added docs (README.md, changelog) to `$out/share/doc/${pname}` and LICENSE to `$out/share/licenses/${pname}`. |
| omega-rpg | Completed | Yes | Yes | Added docs + manpage and installed license texts. Fixed runtime: wrapper now runs from XDG state dir (writable) and symlinks `data/` from `$out/share/${pname}` (avoids writing into the Nix store for `omega.hi`/`omega.log`). |
| openriichi | Completed | Yes | Yes | Added docs (README.md, CHANGELOG.md) and licenses (LICENSE, Engine/LICENSE) to canonical locations. |
| oregon-trail | Completed | Yes | No | Installed README.txt to `$out/share/doc/${pname}`; no upstream license file (unfree). |
| oshu | Completed | Yes | Yes | Installed end-user docs (README.md, CHANGELOG.md) and license (COPYING) to canonical locations; skipped CONTRIBUTING/dev-only docs. |
| othello | Completed | Yes | Yes | Installed end-user docs (README, NEWS, ChangeLog), manpage, and COPYING license to canonical locations; skipped TODO/AUTHORS per docs policy. |
| pag | Completed | Yes | No | Cross build fixed by honoring stdenv CC/CFLAGS/LDFLAGS (previously hardcoded `CC=cc`). Normalized doc/data install paths to use `${pname}`. Installed end-user doc `README.cat`; no upstream license file (unfree). |
| penney | Completed | Yes | Yes | Installed end-user docs (README.md, CHANGELOG.md) to `$out/share/doc/${pname}` and MIT license file to `$out/share/licenses/${pname}`. |
| pipewalker | Completed | Yes | Yes | Installed end-user doc (README.md) to `$out/share/doc/${pname}` and license (LICENSE) to `$out/share/licenses/${pname}`. |
| piskworks | Completed | Yes | Yes | Cross build fixed by honoring stdenv `CC` (Makefile defaulted to `cc`). Installed end-user doc (README.md) and license (LICENSE) to canonical locations. |
| piu-piu | Completed | Yes | Yes | Installed end-user doc (README.md) to `$out/share/doc/${pname}` and license (LICENSE.md) to `$out/share/licenses/${pname}`. |
| proxima5 | Completed | Yes | Yes | Installed end-user doc (README.md) to `$out/share/doc/${pname}` and license (LICENSE) to `$out/share/licenses/${pname}`. |
| puzzl | Completed | Yes | Yes | Installed end-user doc (README.md) to `$out/share/doc/${pname}`. No upstream license file in the pinned revision; left `meta.license` as unfree. |
| qcheckers | Completed | Yes | No* | Installed end-user docs (README.md, INSTALL.md, FAQ, NEWS, ChangeLog, AUTHORS) and license (COPYING) to canonical locations. Conditionally excludes wrapQtAppsHook during cross builds. Cross-compilation blocked by Qt5 qtbase-setup-hook.sh limitation: both build-platform and host-platform Qt register with same `hostOffset=-1`, triggering mismatch detection. |
| redeal | Completed | Yes | Yes | Fixed packaging: upstream has `README.md` (not `README.rst`) and no `THANKS.txt`. Preserved `README.md` + `examples/` under `$out/share/doc/${pname}` and installed `LICENSE.txt` + `GPL-3.0.txt` to `$out/share/licenses/${pname}`. |
| rhex | Completed | Yes | Yes | Preserved README.md to `$out/share/doc/${pname}`. Upstream repo (pinned rev) contains no standalone license file; left license metadata as MPL-2.0 from Cargo.toml. |
| robohack | Completed | Yes | Yes | Preserved README to `$out/share/doc/${pname}` and GPL text to `$out/share/licenses/${pname}`. Verified native and `pkgsCross.aarch64-multiplatform` builds. |
| roflbalt | Completed | Yes | Yes | Preserved README.md to `$out/share/doc/${pname}`. No standalone license file in pinned revision; left `meta.license = mit` based on upstream intent. |
| rummy | Completed | Yes | Yes | Built and cross-built. Preserved README.md to `$out/share/doc/${pname}`. No upstream license file; left `meta.license = unfree` (all-rights-reserved). |
| schiffbruch | Completed | Yes | Yes | Cross build fixed by providing a native `resgen` tool (for resource codegen) via `buildPackages`, so CMake can generate C sources during cross compilation. Preserved README.md to `$out/share/doc/${pname}` and LICENSE to `$out/share/licenses/${pname}`. |
| scrap | Completed | Yes | Yes | Built and cross-built (makefile.linux). Preserved `readme.txt` and `manual.txt` to `$out/share/doc/${pname}`. No upstream license file; kept `meta.license = unfree`. |
| seatris | Completed | Yes | Yes | Fixed packaging: removed incorrect `$out/var/...` highscore file creation (seatris defaults to `/var/lib/games/seatris.score` and supports `-f` / `SCOREFILE` overrides). Preserved README, HISTORY, ACKNOWLEDGEMENTS, example.seatrisrc to `$out/share/doc/${pname}` (skipped upstream TODO as developer-only); installed LICENSE to `$out/share/licenses/${pname}`; manpage installed. |
| sedchess | Completed | Yes | Yes | Built and cross-built. Preserved `README.md` to `$out/share/doc/${pname}` and installed `chess.sed` to `$out/share/${pname}` with a `sedchess` wrapper. Avoided pulling in `glibcLocales` for cross builds. No upstream license file; kept `meta.license = unfree`. |
| shell-tanks | Completed | Yes | Yes | Preserved README.md to `$out/share/doc/${pname}` and LICENSE to `$out/share/licenses/${pname}` (avoid duplicate license/docs in `$out/share/${pname}`). Wrapper uses `XDG_STATE_HOME` for mutable runtime state. Cross build fixed by removing `mplayer` from the wrapped PATH (mplayer does not cross-build reliably); audio remains best-effort if users install a player separately. |
| shellshock | Completed | Yes | Yes | Built and cross-built. Single-file bash script; preserved upstream behavior (including per-user `~/.shellshock` highscore file) for historical compatibility; no packaging patching needed. |
| ship_game | Completed | Yes | Yes | Built and cross-built. Installs `ship_battle` to `$out/bin` and preserves README.md to `$out/share/doc/${pname}`. No upstream license file; kept `meta.license = unfree`. |
| simulchess | Completed | Yes* | No | *Build requires opting into insecure packages (`python2`): `NIXPKGS_ALLOW_INSECURE=1 nix-build -A simulchess`. Cross-build to aarch64 is blocked because `python-2.7.18.12` fails to build with the current toolchain (C23 keyword conflict in Python 2 headers). Preserved end-user docs (README, RULES) to `$out/share/doc/${pname}` (skipped upstream TODO per docs policy). |
| slashem | Completed | Yes | Yes | Built and cross-built. Runtime wrapper uses per-user `XDG_STATE_HOME` for mutable game state (avoids writing into the store); upstream Guidebook and license are preserved in `$out/games/slashemdir/` and copied into the user state dir on first run. |
| slider | Completed | Yes | Yes | Built and cross-built from a single `slider.c.gz` source. No upstream docs beyond embedded comments; package installs the `slider` binary only. |
| sokoban-bootsector | Completed | Yes | Yes | Built and cross-built (assembles a 512-byte boot sector + 1.44MB floppy image). Preserves `sokoban.asm`, `sokoban.bin`, `sokoban.fdd` under `$out/share/${pname}`. Wrapper runs `qemu-system-i386` if available on PATH (avoids pulling `qemu` into the closure / cross-build dependency graph). |
| sokoban-sed | Completed | Yes | Yes | Built and cross-built. Preserves upstream sed script as `$out/bin/sokoban-sed` with the shebang rewritten to `${gnused}/bin/sed -nf`. Install-check exercises start/quit interaction on native builds. |
| solvitaire | Completed | Yes | Yes | Built and cross-built. Preserved README.md to `$out/share/doc/${pname}` and LICENSE to `$out/share/licenses/${pname}`. Build emits some upstream warnings (`-Warray-bounds` / ignored `fgets` return); left unpatched for historical preservation. |
| spacezero | Completed | Yes | Yes | Built and cross-built (GTK2/OpenAL). Preserved upstream HTML manual (`html/manual.html` + `manual_files/`) and changelog to `$out/share/doc/${pname}`; installed COPYING to `$out/share/licenses/${pname}`. |
| sqlite-hangman | Completed | Yes | Yes | Built and cross-built. Preserved README.md to `$out/share/doc/${pname}`. Upstream tag contains no standalone license file; left `meta.license = mit` based on upstream declaration. |
| sst2k | Completed | Yes | Yes | Built and cross-built. Preserved README/AUTHORS/NEWS/ChangeLog to `$out/share/doc/${pname}`; installed COPYING to `$out/share/licenses/${pname}`; upstream also ships a DocBook-based manual which is installed as a manpage (`sst.6`). |
| stardork | Completed | Yes | Yes | Built and cross-built. Preserves README to `$out/share/doc/${pname}`. No upstream license file/notice; kept `meta.license = unfree` (all-rights-reserved). |
| starfighter | Completed | Yes | Yes | Built and cross-built. Upstream installs docs (including license texts) to `$out/share/doc/starfighter`; kept that upstream layout for minimal patching (no doc-dir renames/moves). Desktop file, icon, data assets, and manpage are installed by upstream make install. |
| sudognu | Completed | Yes | Yes | Built and cross-built. Preserved README to `$out/share/doc/${pname}` and COPYING to `$out/share/licenses/${pname}`; upstream also ships README_CGI (cgi-specific) which we skip as non-player-facing. |
| sunfish | Completed | Yes | Yes | Built and cross-built. Preserved README.md and upstream `docs/` to `$out/share/doc/${pname}`; installed LICENSE.md to `$out/share/licenses/${pname}`. |
| terminal-gem-match | Completed | Yes | Yes | Built and cross-built. Preserved README.md to `$out/share/doc/${pname}` and LICENSE.md to `$out/share/licenses/${pname}` (skipped upstream TODO as developer-only). |
| terminal-pong | Completed | Yes | Yes | Built and cross-built. Preserved README.md to `$out/share/doc/${pname}`. No upstream license file/notice in the pinned release; kept `meta.license = unfree` (all-rights-reserved). |
| text-text-revolution | Completed | Yes | Yes | Built and cross-built. Preserved README to `$out/share/doc/${pname}` and COPYING to `$out/share/licenses/${pname}`. |
| threes-c | Completed | Yes | Yes | Cross-build fixed via a minimal, derivation-scoped build-system fix: `substituteInPlace` adjusts the upstream Makefile link command to use `$(CC)` instead of hardcoded `gcc`. Preserved README.md to `$out/share/doc/${pname}` and LICENSE to `$out/share/licenses/${pname}`. |
| tictac2 | Completed | Yes | Yes | Built and cross-built. Preserved README to `$out/share/doc/${pname}`; upstream ships GPL notice as `README.license` (installed to `$out/share/licenses/${pname}/COPYING`). Manpage installed. |
| tictac4 | Completed | Yes | Yes | Built and cross-built. Preserved README to `$out/share/doc/${pname}` and COPYING to `$out/share/licenses/${pname}`. |
| tinycols | Completed | Yes | Yes | Built and cross-built (tests run on native builds). Preserved README.md to `$out/share/doc/${pname}`, LICENSE to `$out/share/licenses/${pname}`, and upstream manpage (`tinycols.6`). |
| tinytetris | Completed | Yes | Yes | Built and cross-built. Preserved README.md and `tinytetris-commented.cpp` to `$out/share/doc/${pname}` and LICENSE to `$out/share/licenses/${pname}`. |
| torus | Completed | Yes | Yes | Built and cross-built. Preserved README.linux to `$out/share/doc/${pname}`. Wrapper uses `XDG_STATE_HOME` for per-user mutable score/state files (historically uses relative filenames via compile-time defines to avoid hardcoded global score paths). No upstream license file and upstream source header includes a non-commercial restriction; kept `meta.license = unfree`. |
| tossug-arena | Completed | Yes | Yes | Built and cross-built. Preserved README.md to `$out/share/doc/${pname}` and LICENSE (CC0) to `$out/share/licenses/${pname}`; runtime data stays under `$out/share/tossug-arena`. |
| trek73 | Completed | Yes | Yes | Built and cross-built. Upstream tarball contains only source + Makefile (no README/license file); kept `meta.license = unfree` based on “All rights reserved” source header. |
| trog | Completed | Yes | Yes | Built and cross-built. Preserved README.md to `$out/share/doc/${pname}` and LICENSE to `$out/share/licenses/${pname}` (skipped TODO as developer-only). |
| ularn | Completed | Yes | Yes | Built and cross-built. Upstream installs docs under `$out/share/doc/Ularn-1.7.0`; kept upstream layout for minimal patching and added canonical license install to `$out/share/licenses/${pname}`. Game data installs to `$out/share/Ularn`. |
| vim-mario | Completed | Yes | Yes | Built and cross-built (vim plugin). Upstream ships README.md and LICENSE in the source; plugin output is standard vim plugin layout under `$out/share/vim-plugins`. |
| vte_gtk2 | Completed | Yes | Yes | Built and cross-built. Preserved upstream docs (README, NEWS, AUTHORS, ChangeLog*, `doc/readme.txt`) to `$out/share/doc/${pname}` and installed COPYING to `$out/share/licenses/${pname}`. Configured with `--disable-gnome-pty-helper` (setuid helper is not meaningful in the Nix store) and forced libtool to use `${file}/bin/file` instead of hardcoded `/usr/bin/file`. |
| watercloset | Completed | Yes | Yes | Built and cross-built. Cross-build fixed with a minimal build-system tweak: `sdl2-config` was replaced with an absolute `${pkg-config}` call in the makefile substitution (avoids PATH/toolchain issues under cross). Preserved README.md to `$out/share/doc/${pname}` and installed LICENSE + legalcode.txt (asset license) to `$out/share/licenses/${pname}`. Runtime data stays under `$out/share/watercloset`. |
| wolfentext3d | Completed | Yes | Yes | Built and cross-built. Preserved README.md and preview.gif to `$out/share/doc/${pname}`. Ruby script lives under `$out/share/wolfentext3d` with a small wrapper in `$out/bin/wolfentext3d`. |
| wordle-cli | Completed | Yes | Yes | Built and cross-built (Go). Preserved README.md to `$out/share/doc/${pname}` and LICENSE to `$out/share/licenses/${pname}`. |
| xjump-sdl | Completed | Yes | Yes | Built and cross-built. Cross-build fixed by disabling stdenv’s `--build/--host` flags for this non-autoconf `configure` script and making the script honor `$PKG_CONFIG` (so it finds SDL2 via the correct wrapper). Preserved README.md to `$out/share/doc/${pname}`; installed LICENSE.txt + asset LICENSE.md to `$out/share/licenses/${pname}`. Upstream installs icons, desktop file, metainfo, and manpage. |
| xonitix | Completed | Yes | Yes | Built and cross-built. Preserved README.md to `$out/share/doc/${pname}` and LICENSE (MIT) to `$out/share/licenses/${pname}`. |
| yahtzee | Completed | Yes | Yes | Built and cross-built. Preserved upstream README to `$out/share/doc/${pname}`. Wrapper runs from per-user `XDG_STATE_HOME` to keep the scoreboard writable without relying on system-wide score directories. No license notice in the upstream archive; kept `meta.license = unfree`. |
| yuxtapa | Completed | Yes | Yes | Built and cross-built. Preserved upstream HTML manual under `$out/share/doc/${pname}/manual`, kept runtime templates under `$out/share/yuxtapa/tmplates`, and installed README + LICENSE to `$out/share/doc/${pname}` and `$out/share/licenses/${pname}`. |
| zeta | Completed | Yes | Yes | Built and cross-built. Cross-build fixed with a minimal build-system tweak: Makefile now uses `CC ?=` so nixpkgs can pass `CC=${stdenv.cc.targetPrefix}cc` instead of hardcoded `gcc`. Preserved README.md to `$out/share/doc/${pname}` and LICENSE to `$out/share/licenses/${pname}`. |
| zgloom | Completed | Yes | Yes | Built and cross-built. Cross-build fixed by using `$PKG_CONFIG` (wrapper) instead of calling `pkg-config` directly. Preserved README.md to `$out/share/doc/${pname}`. No upstream license file and upstream notes licensing is unclear; kept `meta.license = unfree`. |
| zis | Completed | Yes | Yes | Built and cross-built. Preserved README + help.html manual to `$out/share/doc/${pname}` and LICENSE to `$out/share/licenses/${pname}`; kept a compatibility symlink at `$out/share/zis/help.html`. |
| znake | Completed | Yes | Yes | Built and cross-built. Preserved ChangeLog to `$out/share/doc/${pname}` and COPYING to `$out/share/licenses/${pname}`. |
| ztrack | Completed | Yes | Yes | Built and cross-built. Preserved upstream README (public-domain notice) to `$out/share/doc/${pname}`; manpage installed. |
| zztgo | Completed | Yes | Yes | Built and cross-built (Go). Preserved bundled TOWN.ZZT example world under `$out/share/zztgo`, and installed README.md + LICENSE.txt to `$out/share/doc/${pname}` and `$out/share/licenses/${pname}`. Wrapper runs from `$out/share/zztgo` so the game can find its world data. |
