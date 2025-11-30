final: prev: {
  claude-code = prev.claude-code.overrideAttrs (oldAttrs: rec {
    version = "2.0.55";

    src = prev.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      hash = "sha256-wsjOkNxuBLMYprjaZQyUZHiqWl8UG7cZ1njkyKZpRYg=";
    };

    npmDepsHash = "";
  });
}
