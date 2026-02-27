{
  lib,
  vimUtils,
  fetchFromGitHub,
  nix-update-script,
}:

vimUtils.buildVimPlugin {
  pname = "vim-mario";
  version = "0-unstable-2020-01-28";

  src = fetchFromGitHub {
    owner = "rbtnn";
    repo = "vim-mario";
    rev = "c984617e459d9eaebd4f42386c3e848f56ef106f";
    hash = "sha256-OqoRUoJwA9DOyIOQs7EXD9/+8IHhZWmGj671Pkjjpo0=";
  };

  strictDeps = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Super Mario animation in Vim";
    homepage = "https://github.com/rbtnn/vim-mario";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zaczero ];
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
