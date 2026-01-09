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

# Deploy blog - verbose output
[group('servers')]
deploy:
   ansible-playbook -i ansible/inventory.ini ansible/playbooks/deploy.yml -vvv

[group('servers')]
update-glance:
    ansible-playbook -i ansible/inventory.ini ansible/playbooks/restart-glance.yml

[group('servers')]
backup:
  ansible-playbook -i ansible/inventory.ini ansible/playbooks/backup.yml
# Update agenix secrets
[group('servers')]
update-secrets:
  nix flake update secrets

# ==============================
#       ANSIBLE COMMANDS
# ==============================

# Run a specific role
[group('ansible')]
run role:
    ansible-playbook ansible/site.yml --tags {{ role }} --ask-become-pass # --ask-vault-pass

# Run a specific environment (production, dev)
[group('ansible')]
ini env:
  ansible-inventory --list -i ansible/inventory/{{ env }}.yml
#
# [group('ansible')]
# ini-dev:
#   ansible-inventory --list -i ansible/inventory/dev.yml
