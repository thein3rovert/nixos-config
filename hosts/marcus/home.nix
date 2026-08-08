{ self, inputs, ... }:
{
  home-manager.users.thein3rovert = {
    imports = [ self.homeManagerModules.thein3rovert ];
    
    # Enable OpenCode agent management with polis
    ai.agents.opencode = {
      enable = true;
      agentsInput = inputs.polis;
      modelOverrides = {
        ag-quick-chat = "opencode-go/deepseek-v4";
        ag-blog-writer = "anthropic/claude-sonnet-4";
      };
    };
  };
}
