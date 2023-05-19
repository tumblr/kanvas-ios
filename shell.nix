with (import <nixpkgs> {});
let
  env = bundlerEnv {
    name = "KanvasExample-bundler-env";
    inherit ruby_2_7;
    gemfile  = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset   = ./gemset.nix;
  };
in stdenvNoCC.mkDerivation rec {
  name = "KanvasExample";
  buildInputs = [ env ];
}
