{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "puzzl";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "pravj";
    repo = "puzzl";
    rev = "556f95d824fed10934007586214ba7e4248e3a01";
    hash = "sha256-UUTll4xXltjP2o3FHWcH7Euhgys/neDD6vFf53/0MRo=";
  };

  strictDeps = true;

  vendorHash = "sha256-m/ASIIuV5W/KNw1YBXrQTLiTSdHA7R3ir5+Ivb3W6Ns=";

  postPatch = ''
    # Upstream predates Go modules. Avoid network access in `postPatch` by
    # providing a minimal module definition.
    cat > go.mod <<'EOF'
    module github.com/pravj/puzzl

    go 1.17

    require github.com/nsf/termbox-go v1.1.1

    require github.com/mattn/go-runewidth v0.0.9 // indirect
    EOF

    cat > go.sum <<'EOF'
    github.com/mattn/go-runewidth v0.0.9 h1:Lm995f3rfxdpd6TSmuVCHVb/QhupuXlYr8sCI/QdE+0=
    github.com/mattn/go-runewidth v0.0.9/go.mod h1:H031xJmbD/WCDINGzjvQ9THkh0rPKHF+m2gUSrubnMI=
    github.com/nsf/termbox-go v1.1.1 h1:nksUPLCb73Q++DwbYUBEglYBRPZyoXJdrj5L+TkjyZY=
    github.com/nsf/termbox-go v1.1.1/go.mod h1:T0cTdVuOwf7pHQNtfhnEbzHbcNyCEcVU4YPpouCbVxo=
    EOF
  '';

  subPackages = [ "." ];

  postInstall = ''
    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
  '';

  # The game is fully interactive (termbox) and provides no reliable `--version`
  # or `--help` for a non-interactive smoke test in the Nix build sandbox.

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal sliding-puzzle game with a built-in solver";
    homepage = "https://github.com/pravj/puzzl";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ Zaczero ];
    mainProgram = "puzzl";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    platforms = lib.platforms.unix;
  };
})
