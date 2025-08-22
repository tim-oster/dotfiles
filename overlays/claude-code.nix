final: prev: {
  claude-code = prev.claude-code.overrideAttrs (oldAttrs: rec {
    version = "1.0.88";

    src = prev.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      hash = "sha256-o0A9P0sBB2Fk18CArGGv/QBi55ZtFgoJ2/3gHlDwyEU=";
    };

    npmDepsHash = "";
  });
}
