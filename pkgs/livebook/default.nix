#ideas for this derivation borrowed from https://github.com/hauleth/nix-elixir/blob/master/pkgs/livebook.nix

{
  lib,
  beam,
  makeWrapper,
  rebar3,
  elixir_1_14,
  erlang,
  fetchgit,
  ...
}: let
  packages = beam.packagesWith beam.interpreters.erlang;
  elixir = packages.elixir_1_14;
in
packages.mixRelease rec {
  pname = "livebook";
  version = "0.7.2";

  inherit elixir;

  buildInputs = [erlang];

  nativeBuildInputs = [makeWrapper];

  src = fetchgit {
    url = "https://github.com/livebook-dev/livebook.git";
    rev = "v${version}";

    sha256 = "iKD5u/8XCXBXNA588jXji9Kf7zRHGO5D89HsqErQnp0=";
  };

  mixFodDeps = packages.fetchMixDeps {
    pname = "mix-deps-${pname}";
    inherit src version;
    sha256 = "5EQk4RACPTZyOF+fSnUTSHuHt6exmXkBtIyXwVay6lk=";
  };

  installPhase = ''
    mix escript.build
    mkdir -p $out/bin
    mv ./livebook $out/bin
    wrapProgram $out/bin/livebook \
      --suffix PATH : ${lib.makeBinPath [elixir]} \
      --set MIX_REBAR3 ${rebar3}/bin/rebar3
  '';
}
