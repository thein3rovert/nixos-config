# Type Aliases Module

This module provides convenient type aliases for Nix module definitions, reducing verbosity and improving code readability throughout your NixOS configuration.

## Table of Contents

- [Overview](#overview)
- [Enabling the Module](#enabling-the-module)
- [Usage](#usage)
- [Available Aliases](#available-aliases)
- [Examples](#examples)

## Overview

The types module exports a collection of commonly used Nix types and functions as shorter, more memorable aliases. These are accessible through `lib.t` once the module is enabled.

## Enabling the Module

To enable the type aliases in your configuration, set the following option in your `configuration.nix`:

```nix
{
  nixosSetup.profiles.types.enable = true;
}
```

## Usage

Once enabled, you can use the type aliases in any module definition:

```nix
{ lib, ... }: {
  options.myService = {
    enable = lib.t.createEnableOption "My custom service";
    
    port = lib.t.createOption {
      type = lib.t.port;
      default = 8080;
      description = "Port to listen on";
    };
    
    name = lib.t.createOption {
      type = lib.t.string;
      description = "Service name";
    };
  };
  
  config = lib.t.If config.myService.enable {
    # Your configuration here
  };
}
```

## Available Aliases

### Option Functions

| Alias | Original | Description |
|-------|----------|-------------|
| `createOption` | `mkOption` | Create a module option |
| `createEnableOption` | `mkEnableOption` | Create an enable option with default description |
| `If` | `mkIf` | Conditional configuration |
| `mapAttribute` | `mapAttrs` | Map over attribute set |

### Basic Types

| Alias | Original | Description |
|-------|----------|-------------|
| `string` | `types.str` | String type |
| `boolean` | `types.bool` | Boolean type |
| `integer` | `types.int` | Integer type |
| `port` | `types.port` | Port number (0-65535) |
| `package` | `types.package` | Package type |
| `path` | `types.path` | Path type |
| `lines` | `types.lines` | Multi-line string |
| `unspecified` | `types.unspecified` | Unspecified type |
| `raw` | `types.raw` | Raw type (no type checking) |

### Collection Types

| Alias | Original | Description |
|-------|----------|-------------|
| `list` | `types.listOf` | List constructor |
| `attributeSetOf` | `types.attrsOf` | Attribute set constructor |
| `subModule` | `types.submodule` | Submodule constructor |
| `enum` | `types.enum` | Enumeration type |

### Option Types

| Alias | Original | Description |
|-------|----------|-------------|
| `nullOr` | `types.nullOr` | Type that can be null |
| `oneOf` | `types.oneOf` | One of multiple types |
| `either` | `types.either` | Either of two types |

### Composite Types

Pre-configured composite types for common use cases:

| Alias | Definition | Description |
|-------|------------|-------------|
| `listOfStrings` | `types.listOf types.str` | List of strings |
| `listOfPackages` | `types.listOf types.package` | List of packages |
| `attributeSetOfStrings` | `types.attrsOf types.str` | Attribute set of strings |
| `attributeSetOfPackages` | `types.attrsOf types.package` | Attribute set of packages |

## Examples

### Example 1: Basic Service Configuration

```nix
{ lib, config, pkgs, ... }: {
  options.myApp = {
    enable = lib.t.createEnableOption "My Application";
    
    settings = lib.t.createOption {
      type = lib.t.subModule {
        options = {
          host = lib.t.createOption {
            type = lib.t.string;
            default = "localhost";
          };
          
          port = lib.t.createOption {
            type = lib.t.port;
            default = 3000;
          };
          
          debug = lib.t.createOption {
            type = lib.t.boolean;
            default = false;
          };
        };
      };
      default = {};
    };
    
    extraPackages = lib.t.createOption {
      type = lib.t.listOfPackages;
      default = [];
      description = "Additional packages to include";
    };
  };
  
  config = lib.t.If config.myApp.enable {
    environment.systemPackages = config.myApp.extraPackages;
  };
}
```

### Example 2: Complex Configuration with Submodules

```nix
{ lib, config, ... }: {
  options.services.myCluster = {
    enable = lib.t.createEnableOption "My Cluster Service";
    
    nodes = lib.t.createOption {
      type = lib.t.attributeSetOf (lib.t.subModule {
        options = {
          address = lib.t.createOption {
            type = lib.t.string;
            description = "Node address";
          };
          
          port = lib.t.createOption {
            type = lib.t.port;
            default = 7946;
          };
          
          role = lib.t.createOption {
            type = lib.t.enum [ "master" "worker" "backup" ];
            default = "worker";
          };
          
          tags = lib.t.createOption {
            type = lib.t.listOfStrings;
            default = [];
          };
        };
      });
      default = {};
      description = "Cluster nodes configuration";
    };
    
    environment = lib.t.createOption {
      type = lib.t.attributeSetOfStrings;
      default = {};
      description = "Environment variables";
    };
  };
  
  config = lib.t.If config.services.myCluster.enable {
    # Cluster configuration here
  };
}
```

### Example 3: Using nullOr and either

```nix
{ lib, config, ... }: {
  options.backup = {
    enable = lib.t.createEnableOption "Backup Service";
    
    destination = lib.t.createOption {
      type = lib.t.either lib.t.path lib.t.string;
      description = "Backup destination (path or remote URL)";
    };
    
    schedule = lib.t.createOption {
      type = lib.t.nullOr lib.t.string;
      default = null;
      description = "Cron schedule (null to disable scheduled backups)";
    };
    
    retentionDays = lib.t.createOption {
      type = lib.t.nullOr lib.t.integer;
      default = 30;
      description = "Days to keep backups (null for unlimited)";
    };
  };
}
```

### Example 4: Using mapAttribute

```nix
{ lib, config, ... }: {
  options.virtualHosts = lib.t.createOption {
    type = lib.t.attributeSetOf (lib.t.subModule {
      options = {
        serverName = lib.t.createOption { type = lib.t.string; };
        port = lib.t.createOption { type = lib.t.port; };
      };
    });
    default = {};
  };
  
  config = {
    # Map over virtual hosts to create configurations
    services.nginx.virtualHosts = lib.t.mapAttribute (name: cfg: {
      inherit (cfg) serverName;
      listen = [{ inherit (cfg) port; }];
    }) config.virtualHosts;
  };
}
```

## Benefits

1. **Reduced Verbosity**: Shorter names mean less typing and cleaner code
2. **Improved Readability**: Descriptive aliases like `createOption` vs `mkOption`
3. **Consistency**: Standardized aliases across your entire configuration
4. **Easier Learning**: More intuitive names for newcomers to Nix
5. **Type Safety**: Same type checking as standard Nix types

## Notes

- The type aliases are only available when `nixosSetup.profiles.types.enable = true`
- All aliases map to standard NixOS types, so there's no loss of functionality
- You can mix standard types and aliases in the same configuration
- The module is located in `modules/nixos/os/profiles/types/`

## Architecture

```
modules/nixos/os/profiles/types/
├── default.nix           # Module definition with enable option
├── lib/
│   └── types.nix        # Type aliases export
└── README.md            # This file
```

The types are exported through the flake's extended lib:

```nix
# In flake.nix
lib = nixpkgs.lib.extend (final: prev: {
  t = import ./modules/nixos/os/profiles/types/lib/types.nix { lib = final; };
});
```

This makes `lib.t` available throughout your NixOS configuration when the module is enabled.