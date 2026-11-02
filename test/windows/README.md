# Windows fresh-install test

Runs a throwaway Windows 11 VM with [dockur/windows](https://github.com/dockur/windows)
on a Linux Docker host, then does a first-time chezmoi install of this repo inside it.

## 1. Prepare the Proxmox VM (once)

The container needs KVM, so the Docker VM needs nested virtualisation.

On the **PVE host**, check nested virtualisation is on (`Y` or `1`):

```sh
cat /sys/module/kvm_intel/parameters/nested   # Intel
cat /sys/module/kvm_amd/parameters/nested     # AMD
```

If not: `echo "options kvm-intel nested=Y" > /etc/modprobe.d/kvm-intel.conf`
(or `kvm-amd nested=1`), then reboot the host.

For the **Docker VM**:

- CPU type `host`, at least 6 cores; RAM 12 GB or more (8 GB goes to Windows).
- Disk: roughly 200 GB free. That covers the ISO (~8 GB), the Windows disk (up to `DISK_SIZE`) and the golden copy.
- Docker with the compose plugin, plus `rsync`. Check `ls -l /dev/kvm` exists.

## 2. First run (once, ~30 min)

```sh
git clone <dotfiles repo> && cd dotfiles/test/windows
cp .env.example .env    # set STORAGE_DIR, GOLDEN_DIR, WIN_PASSWORD
docker compose up -d
```

Watch the install at `http://<docker-vm>:8006`. When the desktop shows
**Run dotfiles test.cmd**, Windows is ready. Don't run it yet. Save the clean state first:

```sh
./reset.sh save
```

## 3. Each test

```sh
./reset.sh restore
```

1. RDP to `<docker-vm>:3389` as `WIN_USERNAME` / `WIN_PASSWORD`.
2. Double-click **Run dotfiles test.cmd**.
3. Answer chezmoi's prompts, and paste the BWS access token when asked. That step isn't logged.
4. Read the result from the host: `ls -t ../../.test-logs/ | head`.

By default the test copies the checkout on the Docker host (`Z:` in Windows), so
`git pull` or `git switch <branch>` there before restoring. To test a remote instead:

```powershell
Z:\test\windows\oem\run-test.ps1 -Repo https://github.com/markkpamy/dotfiles.git
```

Edits to `oem/run-test.ps1` take effect on the next run, since the launcher reads it from `Z:`.
Edits to `oem/install.bat` only apply to a new base install: delete `STORAGE_DIR` and `GOLDEN_DIR`, then repeat step 2.

## Secrets

- After `chezmoi init` the token sits in the VM's `~/.config/chezmoi/chezmoi.toml`.
  `reset.sh restore` overwrites that disk. Never `save` after a test run.
- Prefer a dedicated BWS machine account for this VM: read-only, scoped, with an expiry.
- `.test-logs/` holds verbose `chezmoi apply` output and is gitignored. Treat it as sensitive.
