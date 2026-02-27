{
  lib,
  stdenv,
  fetchgit,
  unstableGitUpdater,
  installShellFiles,
  ncurses,
  python3,
  xmlto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sst2k";
  version = "0-unstable-2012-06-24";

  src = fetchgit {
    url = "https://git.code.sf.net/p/sst2k/code";
    rev = "98aa20fb7406748fff65bc8f2d4ec208912beec6"; # c_version branch
    hash = "sha256-kMYyaXDEuWLFRtLxAF57hSscC5kqodYFjchKOY0dglU=";
  };

  nativeBuildInputs = [
    installShellFiles
    python3
    xmlto
  ];

  buildInputs = [
    ncurses
  ];

  strictDeps = true;

  configureFlags = [
    "--disable-nls"
  ];

  hardeningDisable = [
    "format"
  ];

  makeFlags = [
    "-C"
    "src"
  ];

  postBuild = ''
    (cd doc && xmlto --skip-validation man sst.xml)
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  checkPhase = ''
    runHook preCheck

    strings src/sst | grep -Fq "usage: sst"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 src/sst -t "$out/bin"
    installManPage doc/sst.6

    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 README AUTHORS NEWS ChangeLog -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 COPYING -t $out/share/licenses/${finalAttrs.pname}
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://git.code.sf.net/p/sst2k/code";
    branch = "c_version";
    hardcodeZeroVersion = true;
  };

  meta = {
    description = "Super Star Trek (C version) classic terminal strategy game";
    homepage = "https://sourceforge.net/projects/sst2k/";
    license = lib.licenses.bsd3;
    mainProgram = "sst";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
