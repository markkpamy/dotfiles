# Windows fresh-install test

Runs a throwaway Windows 11 VM, then does a first-time chezmoi install of this repo inside it.
Three ways to host the VM; all use the same test script, `oem/run-test.ps1`:

- **Hyper-V on this Windows machine**: see [Hyper-V](#hyper-v-windows-host-without-docker) below.
  Use this when Docker Desktop can't get `/dev/kvm` (WSL reports `Hyper-V: Nested features: 0x0`).
- **Docker Desktop** or a **Linux Docker host**, with [dockur/windows](https://github.com/dockur/windows).

## Hyper-V (Windows host, without Docker)

Windows runs natively under Hyper-V, so no nested virtualisation is needed. Scripts are in `hyperv/`
and must run from an **elevated** PowerShell (or join the *Hyper-V Administrators* group).

1. Download a Windows 11 ISO from Microsoft. Its language must match `-UILanguage` (default `en-US`);
   the keyboard layout and regional format default to this machine's.
2. Create the VM. It asks for a password for the VM's local account (`tester`), then installs
   Windows 11 Pro unattended (~20 min) into `E:\Hyper-V\dotfiles-windows-test` (6 GB RAM, 4 CPUs, 96 GB disk):

   ```powershell
   cd test\windows\hyperv
   .\vm.ps1 create -IsoPath <path-to-Win11.iso>
   ```

3. When the desktop shows **Run dotfiles test**, save the clean state: `.\vm.ps1 save`.
4. Each test:
   1. `.\vm.ps1 restore` reverts to the clean checkpoint, boots, copies this checkout in
      (uncommitted changes included) and opens the console.
   2. In the VM, double-click **Run dotfiles test**, answer the chezmoi prompts, paste the BWS token.
      To paste in the console window: *Clipboard → Type clipboard text*.
   3. `.\vm.ps1 logs` copies the VM's `C:\test-logs` into this repo's `.test-logs/` (asks for the VM password).

Other actions: `push` (copy the checkout into a running VM again), `status`, `remove`.
The VM password is written in plain text to the VM's answer file (`unattend.iso` in the VM folder,
and inside Windows). Use a throwaway password.

## dockur/windows (Docker)

Two host versions share `compose.yml` and `oem/`:

|                 | Windows host (Docker Desktop)   | Linux host (e.g. Proxmox VM)  |
| --------------- | ------------------------------- | ----------------------------- |
| `.env` template | `.env.windows.example`          | `.env.linux.example`          |
| Compose overlay | `compose.windows.yml`           | `compose.linux.yml`           |
| VM disk         | Docker volume                   | host folder `STORAGE_DIR`     |
| Golden copy     | volume `dotfiles-windows-golden` | host folder `GOLDEN_DIR`      |
| Reset script    | `reset.ps1`                     | `reset.sh`                    |
| Viewer / RDP    | `localhost:8006` / `:3390`      | `<host>:8006` / `:3389`       |

`.env` selects the overlay through `COMPOSE_FILE`, so the `docker compose` commands are the same on both.

## 1. Prepare the host (once)

dockur needs KVM (`/dev/kvm`) and about 8 GB of free RAM for the 6 GB guest (RAM_SIZE).

### Windows host: Docker Desktop

Docker Desktop runs inside WSL2, so `~/.wslconfig` (managed here as `home/dot_wslconfig`) must give
WSL enough memory and nested virtualisation:

```ini
[wsl2]
memory=12GB
processors=8
nestedVirtualization=true
```

After changing it: quit Docker Desktop, run `wsl --shutdown`, start Docker Desktop again. Check:

```powershell
docker info --format '{{.MemTotal}} {{.NCPU}}'            # ~12 GB, 8
docker run --rm --device /dev/kvm alpine ls -l /dev/kvm   # must list the device
```

If `/dev/kvm` is missing: turn on AMD SVM / Intel VT-x in the BIOS/UEFI, and enable the Windows
features *Virtual Machine Platform* and *Hyper-V*.

### Linux host: Proxmox VM

On the **PVE host**, nested virtualisation must be on (`Y` or `1`):

```sh
cat /sys/module/kvm_intel/parameters/nested   # Intel
cat /sys/module/kvm_amd/parameters/nested     # AMD
```

If not: `echo "options kvm-intel nested=Y" > /etc/modprobe.d/kvm-intel.conf`
(or `kvm-amd nested=1`), then reboot the host.

For the **Docker VM**: CPU type `host`; RAM 12 GB or more with ballooning off (`balloon: 0`) and
some swap, or the OOM killer stops QEMU mid-install; ~200 GB free disk; Docker with the compose
plugin, plus `rsync`. Check `ls -l /dev/kvm` exists. Prefer a dedicated VM over one running services.

## 2. First run (once, ~30 min)

Windows host:

```powershell
cd test\windows
Copy-Item .env.windows.example .env    # set WIN_PASSWORD
docker compose up -d
```

Linux host:

```sh
cd test/windows
cp .env.linux.example .env             # set STORAGE_DIR, GOLDEN_DIR, WIN_PASSWORD
docker compose up -d
```

Watch the install in the web viewer (see table). When the desktop shows
**Run dotfiles test.cmd**, Windows is ready. Don't run it yet. Save the clean state first:
`.\reset.ps1 save` (Windows) or `./reset.sh save` (Linux).

## 3. Each test

1. `.\reset.ps1 restore` or `./reset.sh restore`.
2. RDP in as `WIN_USERNAME` / `WIN_PASSWORD` (Windows host: `mstsc /v:localhost:3390`).
3. Double-click **Run dotfiles test.cmd**.
4. Answer chezmoi's prompts, and paste the BWS access token when asked. That step isn't logged.
5. Read the result in the repo's `.test-logs/` folder.

The test copies the checkout mounted as `Z:`, uncommitted changes included. On a Linux host that is
the checkout on that host, so `git pull` / `git switch` there first. To test a remote instead:

```powershell
Z:\test\windows\oem\run-test.ps1 -Repo https://github.com/markkpamy/dotfiles.git
```

Edits to `oem/run-test.ps1` take effect on the next run, since the launcher reads it from `Z:`.
Edits to `oem/install.bat` only apply to a new base install. Delete the VM disk and the golden copy, then repeat step 2:

- Windows host: `docker compose down -v; docker volume rm dotfiles-windows-golden`
- Linux host: `docker compose down`, then empty `STORAGE_DIR` except `*.iso`, and delete `GOLDEN_DIR`

## Secrets

- After `chezmoi init` the token sits in the VM's `~/.config/chezmoi/chezmoi.toml`.
  A restore overwrites that disk. Never `save` after a test run.
- Prefer a dedicated BWS machine account for this VM: read-only, scoped, with an expiry.
- `.test-logs/` holds verbose `chezmoi apply` output and is gitignored. Treat it as sensitive.
- The web viewer has no login. Keep `BIND_ADDR=127.0.0.1` unless you need LAN access.
