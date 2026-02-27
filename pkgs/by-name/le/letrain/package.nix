{
  lib,
  fetchFromGitHub,
  makeWrapper,
  maven,
  jre,
  nix-update-script,
}:

maven.buildMavenPackage {
  pname = "letrain";
  version = "1.0.0-alpha.1-unstable-2023-08-30";

  src = fetchFromGitHub {
    owner = "antoniovazquezaraujo";
    repo = "LeTrain";
    rev = "e6e40c8be364d4c5c1e68bd2555cc2a3553ca0cb";
    hash = "sha256-WHOfPPLRDGiLXjTm6AU4t+V3eRaY3Rds2JrqSueJZAk=";
  };

  strictDeps = true;

  mvnHash = "sha256-KoyYJ7NQ7qDaDW+Oep6k12w2AIq/4UCjdNT2eaGRhG8=";

  nativeBuildInputs = [
    makeWrapper
  ];

  mvnParameters = "package";

  installPhase = ''
    runHook preInstall

    install -Dm644 target/JLeTrain-1.0-SNAPSHOT-jar-with-dependencies.jar -T "$out/lib/letrain.jar"

    install -d "$out/bin"
    makeWrapper ${jre}/bin/java $out/bin/letrain \
      --add-flags "-jar $out/lib/letrain.jar"

    install -Dm644 README.md LICENSE commands.txt -t "$out/share/doc/letrain"
    cp -a images "$out/share/doc/letrain/"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Train simulator for the ASCII terminal";
    homepage = "https://github.com/antoniovazquezaraujo/LeTrain";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "letrain";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
}
