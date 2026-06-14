# ssh

SSH host aliases and which key to use for each.

## Files

- `config` — host entries for personal GitHub and 42 GitHub.

## Hosts

- `github.com` → `~/.ssh/id_rsa_perso`
- `42.github.com` → connects to github.com using `~/.ssh/id_rsa_42`

Both add the key to the agent.

## Notes

The installer doesn't link this — your live `~/.ssh/config` usually differs per
machine, so reconcile it by hand. Keep permissions tight:

```sh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
```
