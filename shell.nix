let nixpkgs = import <nixpkgs> {};
in with nixpkgs;
with stdenv;
with stdenv.lib;
let gems = buildEnv {
  name = "gem-env";
  pathsToLink = ["/lib" "/bin" "nix-support"];
  paths = [
    (bundler.override {
      ruby = jruby;
    })
    (buildRubyGem rec {
      ruby = jruby;
      name = "${gemName}-${version}";
      gemName = "hello-world";
      version = "1.2.0";
      source.sha256 = "141r6pafbwjf8aczsilxxhdrdbbmdhimgbsq8m9qsvjm522ln15p";
    })

  ];
};
in
mkShell {
  name = "jruby-bundler-shell";
  buildInputs = [ jruby ];
  shellHook = ''
      export GEM_NIX_ENV=${gems}/${jruby.gemPath}
      export GEM_USER_DIR=$(pwd)/.gem
      export GEM_DEFAULT_DIR=$(${jruby}/bin/ruby -e 'puts Gem.default_dir')
      export GEM_PATH=$GEM_DEFAULT_DIR:$GEM_PATH:$GEM_NIX_ENV
      export GEM_HOME=$GEM_USER_DIR
      export PATH=$GEM_HOME/bin:$GEM_NIX_ENV/bin:$PATH
  '';
}
