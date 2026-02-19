# user-info

Cross-platform user and host context scripts for quick defensive triage.

## Files

- `info-linux.sh` — Linux user/session/account snapshot
- `info-windows.ps1` — Windows local user/group/logon snapshot

## Linux usage

```bash
chmod +x info-linux.sh
./info-linux.sh
./info-linux.sh --deep
./info-linux.sh --max-history 20
```

## Windows usage

```powershell
# PowerShell as Administrator recommended
Set-ExecutionPolicy -Scope Process Bypass
.\info-windows.ps1
.\info-windows.ps1 -MaxEvents 20
```

## Notes

- Scripts are read-only and intended for **authorized** security assessment.
- Some data (security logs, all crontabs, full process/file lists) may require elevated privileges.
- `--deep` mode on Linux performs heavier checks.
