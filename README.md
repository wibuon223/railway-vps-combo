# Railway VPS Combo

Ubuntu 24.04 SSH VPS for [Railway](https://railway.app), combining the best of two repos:

| Part | Source | What it gives |
|---|---|---|
| Base OS + tools | [minhdevtry/railway-vps](https://github.com/minhdevtry/railway-vps) | Ubuntu 24.04 LTS, OpenSSH with keep-alive, nmap, tmux/screen, node, python3, git, gcc, htop/btop, jq, sqlite, zsh |
| Public tunnel | [AdityaHalder/railway-vps](https://github.com/AdityaHalder/railway-vps) | Free [Pinggy](https://pinggy.io) TCP tunnel, no extra token needed |

## How it works

Railway containers have **no public IP and no open inbound ports**. So on boot,
`entrypoint.sh` starts `sshd` on port 22, then opens a reverse tunnel:

```
ssh -R0:localhost:22 tcp@a.pinggy.io
```

and prints the public endpoint to the runtime logs:

```
Host     : xxx.run.pinggy-free.link
Port     : 45589
Username : root
Password : <ROOT_PASSWORD or auto-generated>
ssh root@xxx.run.pinggy-free.link -p 45589
```

## Variables

| Variable | Required | Description |
|---|---|---|
| `ROOT_PASSWORD` (or `PASSWORD`) | No | Root password. If empty, a random one is generated and printed in the logs (Aditya style). |
| `SSH_PUB_KEY` (or `AUTHORIZED_KEYS`) | No | Your `~/.ssh/id_*.pub` for key auth. |

## Deploy

New Project → Deploy from this repo. No domain/TCP-proxy setup needed —
the Pinggy endpoint appears in **Deployments → View Logs** within ~1 minute
after `SUCCESS`.

## Limits (Railway side, not this repo)

Default trial container: **2 vCPU / 1 GB RAM**. `/proc` shows the host's
specs (EPYC, 322 GB…) — the real quota is in cgroups:

```bash
cat /sys/fs/cgroup/cpu.max
cat /sys/fs/cgroup/memory.max
```

Storage is **ephemeral**: redeploy wipes everything outside a Railway volume.
The Pinggy endpoint also changes on restart (free tier).
