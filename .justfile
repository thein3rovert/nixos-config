# just is a command runner, Justfile is very similar to Makefile, but simpler.
############################################################################
#
#  Common recipes
#
############################################################################

# List all recipes.
_default:
    @printf '\033[1;36mnixcfg recipes\033[0m\n\n'
    @printf '\033[1;33mUsage:\033[0m just <recipe> [args...]\n\n'
    @just --list --list-heading $'Available recipes:\n\n'


[group('jnix')]
info:
  jnix info

[group('jnix')]
dry-run:
  jnix fs-dryrun

[group('jnix')]
clean:
  jnix fs

# Ping all servers
[group('servers')]
ping:
    ansible-playbook -i ansible/inventory.ini ansible/playbooks/ping.yml

[group('servers')]
update-glance:
    ansible-playbook -i ansible/inventory.ini ansible/playbooks/restart-glance.yml

# Update agenix secrets
[group('servers')]
update-secrets:
  nix flake update secrets 
