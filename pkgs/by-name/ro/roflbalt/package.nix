{
  lib,
  ruby,
  buildRubyGem,
  fetchFromGitHub,
  nix-update-script,
}:

buildRubyGem rec {
  inherit ruby;

  gemName = "roflbalt";
  pname = gemName;
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "pda";
    repo = "roflbalt";
    rev = "2a10ee91ae10d72c907dec9357bad8aa87c9fdb1";
    hash = "sha256-BgTHdxqCiwu5tGsX04ay1fZiIICxiIONVw/7YFduYD0=";
  };

  strictDeps = true;

  checkPhase = ''
    runHook preCheck

    ruby -c bin/roflbalt >/dev/null
    ruby -c lib/roflbalt.rb >/dev/null

    runHook postCheck
  '';

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${pname}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Canabalt-inspired ASCII side-scroller for the terminal";
    homepage = "https://github.com/pda/roflbalt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "roflbalt";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
}
