{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "zztgo";
  version = "0-unstable-2020-05-29";

  src = fetchFromGitHub {
    owner = "benhoyt";
    repo = "zztgo";
    rev = "9edb1452d887852c5c68cae0a91a6227cd4ef7a9";
    hash = "sha256-Wz9xAcsT27scuR78X6+17l0RExpmh0uTQUOcQ9lHIkI=";
  };

  strictDeps = true;

  vendorHash = "sha256-0hOXo7Ww34yI5yrz4CDMuFZjPj9CqtmWxQoc9aEBFOs=";

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = ''
    install -Dm644 TOWN.ZZT -t "$out/share/zztgo"

    install -d "$out/libexec"
    mv "$out/bin/zztgo" "$out/libexec/zztgo"
    makeWrapper "$out/libexec/zztgo" "$out/bin/zztgo" \
      --chdir "$out/share/zztgo"

    install -Dm644 README.md -t $out/share/doc/${finalAttrs.pname}
    install -Dm644 LICENSE.txt -t $out/share/licenses/${finalAttrs.pname}
  '';

  passthru.updateScript = nix-update-script {

    extraArgs = [ "--version=branch" ];

  };
  meta = {
    description = "Port of ZZT to Go using tcell";
    homepage = "https://github.com/benhoyt/zztgo";
    license = lib.licenses.mit;
    mainProgram = "zztgo";
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
