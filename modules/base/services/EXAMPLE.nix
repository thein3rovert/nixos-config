# Example Configuration for Base Services Control
# This file shows how to use the homelab.services module

{
  # ============================================
  # OPTION 1: Shared Configuration
  # Place in a shared config file imported by all hosts
  # ============================================
  homelab = {
    enable = true;
    
    services = {
      # Global master switch - controls all hosts
      enable = true;
      
      # Per-host service control
      hosts = {
        # Production application server
        bellamy = {
          enable = true;
          description = "Production server running web services";
        };
        
        # Storage-only server
        kira = {
          enable = false;
          description = "Dedicated storage server - no web services";
        };
        
        # Development server
        spike = {
          enable = true;
          description = "Development and testing environment";
        };
      };
    };
  };

  # ============================================
  # OPTION 2: In Individual Host Config
  # Place directly in hosts/bellamy/default.nix
  # ============================================
  # homelab.services.hosts.bellamy.enable = true;  # or false to disable
  
  # Then configure services normally:
  # nixosSetup.services = {
  #   traefik.enable = true;
  #   memos.enable = true;
  #   # ... other services
  # };
  
  # ============================================
  # OPTION 3: Maintenance Mode
  # Temporarily disable all services
  # ============================================
  # homelab.services.enable = false;  # Disables EVERYTHING
}
