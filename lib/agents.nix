# Harness-agnostic agent management utilities
#
# WHAT THIS FILE IS
# -----------------
# Public entry-point + dispatcher for the agent-management library.
# All heavy lifting (per-tool rendering) lives in `./agents/<tool>.nix`:
#
#   lib/agents/helpers.nix     — shared helpers (parseRule, renderAgentFiles)
#   lib/agents/opencode.nix    — renderForOpencode
#   lib/agents/pi.nix          — renderForPi
#
# This file just imports those and exposes the public API:
#
#   loadCanonical          — load canonical agent definitions from flake input
#   renderForOpencode      — produce agents/*.md for OpenCode
#   renderForPi            — produce AGENTS.md + SYSTEM.md + agents/ for Pi
#   renderForTool          — dispatcher: pick the right renderer by tool name
#   shellHookForTool       — produce a devShell shellHook that symlinks the
#                            rendered files into the project
#
# Usage in your configuration:
#
#   let
#     m3taLib = inputs.m3ta-nixpkgs.lib.${system};
#     canonical = m3taLib.agents.loadCanonical { agentsInput = inputs.agents; };
#
#     rendered = m3taLib.agents.renderForOpencode {
#       inherit pkgs canonical;
#       modelOverrides = { chiron = "anthropic/claude-sonnet-4"; };
#     };
#   in { ... }
{ lib }:

let
  # ── Shared helpers (parseRule + renderAgentFiles) ─────────────
  helpers = import ./agents/helpers.nix { inherit lib; };

  # ── Per-tool modules ──────────────────────────────────────────
  opencodeLib = import ./agents/opencode.nix { inherit lib helpers; };
  # renderForPi = import ./agents/pi.nix { inherit lib helpers; };

  # ── Extract functions from opencode module ────────────────────
  loadAgents = opencodeLib.loadAgents;
  renderForOpencode = opencodeLib.renderForOpencode;

  # ── loadCanonical (legacy) ────────────────────────────────────
  # Load canonical agent definitions from the AGENTS flake input.
  # Returns the canonical attrset from lib.loadAgents (keyed by slug).
  # NOTE: This assumes the flake input has lib.loadAgents - for polis use loadAgents directly
  loadCanonical = { agentsInput }: 
    if agentsInput ? lib.loadAgents 
    then agentsInput.lib.loadAgents 
    else loadAgents { agentsDir = "${agentsInput}/agents"; };

  agentsLib = {
    # Re-export imported functions + loadCanonical
    inherit
      loadCanonical
      loadAgents
      renderForOpencode
      # renderForPi
      ;

    # ── renderForTool dispatcher ──────────────────────────────────
    #
    # Dispatches to the correct renderer by tool name.
    # tool: "opencode" | "claude-code" | "pi"
    #
    # EXAMPLE
    #   m3taLib.agents.renderForTool {
    #     pkgs = pkgs;
    #     agentsInput = inputs.agents;
    #     tool = "opencode";
    #     modelOverrides = { chiron = "anthropic/claude-sonnet-4"; };
    #   }
    renderForTool =
      {
        pkgs,
        agentsInput,
        tool,
        modelOverrides ? { },
        codingRules ? null,
      }:
      let
        # Load agents from polis/agents directory
        canonical = loadAgents { agentsDir = "${agentsInput}/agents"; };
      in
      if tool == "opencode" then
        renderForOpencode { inherit pkgs canonical modelOverrides; }
      # else if tool == "pi" then
      #   renderForPi {
      #     inherit
      #       pkgs
      #       canonical
      #       modelOverrides
      #       codingRules
      #       ;
      #   }
      else
        throw "lib.agents.renderForTool: unknown tool '${tool}'. Must be opencode."; # TODO: Add pi support

    # ── shellHookForTool ─────────────────────────────────────────
    #
    # Generates a shellHook string for use in devShells that symlinks
    # rendered agent files into the project directory.
    #
    # Usage:
    #   devShells.default = pkgs.mkShell {
    #     shellHook = m3taLib.agents.shellHookForTool {
    #       inherit pkgs;
    #       agentsInput = inputs.agents;
    #       tool = "opencode";
    #       modelOverrides = { chiron = "anthropic/claude-sonnet-4"; };
    #     };
    #   };
    shellHookForTool =
      {
        pkgs,
        agentsInput,
        tool,
        modelOverrides ? { },
        codingRules ? null,
      }:
      let
        rendered = agentsLib.renderForTool {
          inherit
            pkgs
            agentsInput
            tool
            modelOverrides
            codingRules
            ;
        };
      in
      if tool == "opencode" then
        ''
          # Agent files for OpenCode
          mkdir -p .opencode/agents
          ln -sfn ${rendered}/* .opencode/agents/
        ''
      else if tool == "pi" then
        ''
          # Agent files for Pi
          ln -sfn ${rendered}/AGENTS.md AGENTS.md
          mkdir -p .pi
          ln -sfn ${rendered}/SYSTEM.md .pi/SYSTEM.md
          mkdir -p .pi/agents
          ln -sfn ${rendered}/agents/* .pi/agents/
        ''
      else
        throw "lib.agents.shellHookForTool: unknown tool '${tool}'";
  };
in
agentsLib
