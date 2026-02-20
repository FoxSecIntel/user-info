# user-info

Cross-platform user and host context scripts for quick defensive triage.

This repo is focused on **fast situational awareness** for responders: who is on the box, who logged in recently, what privileged accounts exist, and whether there are obvious user-level risk signals.

---

## Included scripts

- `info-linux.sh` — Linux user/session/account snapshot
- `info-windows.ps1` — Windows local user/group/logon snapshot

---

## Linux (`info-linux.sh`)

### Usage

```bash
chmod +x info-linux.sh
./info-linux.sh
./info-linux.sh --deep
./info-linux.sh --max-history 20
```

### What it reports

- Host reference context (time, host, user, UID/GID)
- Logged-in users
- Recent login activity
- UID 0 accounts
- Sorted `/etc/passwd`
- Current user crontab
- Recent shell history (configurable)
- Large files in `$HOME`
- Optional deep checks (`--deep`): open files + SUID/SGID under `/home`

---

## Windows (`info-windows.ps1`)

### Usage

```powershell
# PowerShell as Administrator recommended
Set-ExecutionPolicy -Scope Process Bypass
.\info-windows.ps1
.\info-windows.ps1 -MaxEvents 20
```

### What it reports

- Local users and account state
- Administrators group membership (high privilege indicator)
- Per-user quick summary (enabled, last logon, password state)
- Recent successful logon events (Event ID 4624)

---

## Operational notes

- Scripts are **read-only** and intended for authorized security assessment.
- Some checks require elevated privileges to return complete output.
- `--deep` on Linux is heavier and may be slower on larger hosts.
- Missing tool/access conditions are handled gracefully where possible.

---

## Suggested use in incident response

1. Run script and save output to case notes.
2. Compare privileged accounts with expected baseline.
3. Review latest logon patterns for anomalies.
4. Escalate any unknown admin-equivalent account activity.

---

## Legal

Use only on systems you own or are explicitly authorized to assess.
