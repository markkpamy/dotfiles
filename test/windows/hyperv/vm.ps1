#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Hyper-V version of the Windows fresh-install test: a Windows 11 VM with a clean checkpoint.

.DESCRIPTION
    create   Create the VM and install Windows 11 Pro unattended from -IsoPath (~20 min).
    save     Shut the VM down, detach the install media and take the "clean" checkpoint.
    restore  Go back to "clean", start the VM, copy this repo in, open the console.
    push     Copy this repo (working tree, uncommitted changes included) into the running VM.
    logs     Copy the VM's C:\test-logs into the repo's .test-logs (asks for the VM password).
    status   Show the VM and its checkpoints.
    remove   Delete the VM and its files.

    Runs from an elevated PowerShell (Hyper-V needs admin, or membership of "Hyper-V Administrators").
    Inside the VM, double-click "Run dotfiles test" on the desktop: it unpacks the repo and runs
    test/windows/oem/run-test.ps1, which installs chezmoi and asks the chezmoi prompts.

.EXAMPLE
    .\vm.ps1 create -IsoPath E:\ISO\Win11_25H2_English_x64.iso
    .\vm.ps1 save          # once, after the desktop shows "Run dotfiles test"
    .\vm.ps1 restore       # before every test
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]   # only 'remove' asks
param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet('create', 'save', 'restore', 'push', 'logs', 'status', 'remove')]
    [string]$Action,

    [string]$Name = 'dotfiles-windows-test',
    [string]$VMPath = 'E:\Hyper-V',
    [string]$IsoPath,
    [string]$UserName = 'tester',
    [int64]$MemoryBytes = 6GB,
    [int]$ProcessorCount = 4,
    [int64]$DiskBytes = 96GB,
    [string]$SwitchName = 'Default Switch',
    # Must be a language contained in the ISO.
    [string]$UILanguage = 'en-US',
    # Defaults to this machine's keyboard layout and regional format.
    [string]$InputLocale = ((Get-WinUserLanguageList)[0].InputMethodTips | Select-Object -First 1),
    [string]$Locale = (Get-Culture).Name,
    [string]$ImageName = 'Windows 11 Pro'
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$vmDir = Join-Path $VMPath $Name
$checkpoint = 'clean'
$guestZip = 'C:\dotfiles-src.zip'

function Get-TestVM { Get-VM -Name $Name -ErrorAction SilentlyContinue }

function Wait-Heartbeat([int]$TimeoutSec = 600) {
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        $hb = Get-VMIntegrationService -VMName $Name -Name Heartbeat
        if ($hb.PrimaryStatusDescription -eq 'OK') { return }
        Start-Sleep -Seconds 3
    }
    throw "VM $Name did not report a heartbeat within $TimeoutSec s."
}

# Gen2 VMs show "Press any key to boot from CD or DVD" once; press Enter for it.
function Send-BootKeys([int]$Seconds = 15) {
    $cs = Get-CimInstance -Namespace root\virtualization\v2 -ClassName Msvm_ComputerSystem -Filter "ElementName='$Name'"
    $kb = Get-CimAssociatedInstance -InputObject $cs -ResultClassName Msvm_Keyboard
    $end = (Get-Date).AddSeconds($Seconds)
    while ((Get-Date) -lt $end) {
        Invoke-CimMethod -InputObject $kb -MethodName TypeKey -Arguments @{ keyCode = 13 } | Out-Null
        Start-Sleep -Milliseconds 500
    }
}

# Build an ISO from a folder with the built-in IMAPI2 COM API (no Windows ADK needed).
function New-IsoFile([string]$SourceDir, [string]$Path, [string]$Label) {
    if (-not ('ISOFile' -as [type])) {
        $src = @'
public class ISOFile {
    public unsafe static void Create(string path, object stream, int blockSize, int totalBlocks) {
        int bytes = 0;
        byte[] buf = new byte[blockSize];
        var ptr = (System.IntPtr)(&bytes);
        var input = stream as System.Runtime.InteropServices.ComTypes.IStream;
        using (var output = System.IO.File.OpenWrite(path)) {
            while (totalBlocks-- > 0) { input.Read(buf, blockSize, ptr); output.Write(buf, 0, bytes); }
        }
    }
}
'@
        if ($PSVersionTable.PSEdition -eq 'Core') {
            Add-Type -TypeDefinition $src -CompilerOptions '/unsafe'
        } else {
            $cp = New-Object CodeDom.Compiler.CompilerParameters
            $cp.CompilerOptions = '/unsafe'
            Add-Type -TypeDefinition $src -CompilerParameters $cp
        }
    }
    $fsi = New-Object -ComObject IMAPI2FS.MsftFileSystemImage
    $fsi.FileSystemsToCreate = 3   # ISO9660 + Joliet
    $fsi.VolumeName = $Label
    $fsi.Root.AddTree($SourceDir, $false)
    $img = $fsi.CreateResultImage()
    if (Test-Path $Path) { Remove-Item $Path -Force }
    [ISOFile]::Create($Path, $img.ImageStream, $img.BlockSize, $img.TotalBlocks)
}

function Push-Repo {
    $zip = Join-Path $env:TEMP "$Name-src.zip"
    if (Test-Path $zip) { Remove-Item $zip -Force }
    Write-Host "Packing $repoRoot (working tree, uncommitted changes included)"
    # Windows' bsdtar writes a zip when the name ends in .zip. Full path: Git's GNU tar may come first on PATH.
    & "$env:SystemRoot\System32\tar.exe" -a -c -f $zip -C $repoRoot `
        --exclude=node_modules --exclude=.cache_ggshield --exclude=.idea --exclude=.claude --exclude=.test-logs .
    if ($LASTEXITCODE) { throw "tar failed with exit code $LASTEXITCODE" }
    Write-Host "Copying it into the VM as $guestZip"
    Copy-VMFile -Name $Name -SourcePath $zip -DestinationPath $guestZip -FileSource Host -CreateFullPath -Force
    Remove-Item $zip -Force
}

switch ($Action) {
    'create' {
        if (Get-TestVM) { throw "VM $Name already exists. Use '.\vm.ps1 remove' first." }
        if (-not $IsoPath -or -not (Test-Path $IsoPath)) { throw 'Pass -IsoPath <Windows 11 ISO>.' }
        if (-not (Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue)) { throw "No Hyper-V switch named '$SwitchName'." }

        $secure = Read-Host "Password for the VM's local account '$UserName'" -AsSecureString
        $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
        if (-not $plain) { throw 'Empty password.' }

        New-Item -ItemType Directory -Force -Path $vmDir | Out-Null

        # Answer file + launcher on a small second ISO; Setup scans CD drives for autounattend.xml.
        $stage = Join-Path $vmDir 'unattend'
        New-Item -ItemType Directory -Force -Path $stage | Out-Null
        $esc = { param($s) [Security.SecurityElement]::Escape($s) }
        $xml = (Get-Content -Raw (Join-Path $PSScriptRoot 'autounattend.xml')).
            Replace('{{UILANGUAGE}}', (& $esc $UILanguage)).
            Replace('{{INPUTLOCALE}}', (& $esc $InputLocale)).
            Replace('{{LOCALE}}', (& $esc $Locale)).
            Replace('{{IMAGENAME}}', (& $esc $ImageName)).
            Replace('{{COMPUTERNAME}}', 'DOTFILES-TEST').
            Replace('{{USERNAME}}', (& $esc $UserName)).
            Replace('{{PASSWORD}}', (& $esc $plain))
        [IO.File]::WriteAllText((Join-Path $stage 'autounattend.xml'), $xml, (New-Object Text.UTF8Encoding $false))
        Copy-Item (Join-Path $PSScriptRoot '..\oem\run-test.cmd') $stage
        $unattendIso = Join-Path $vmDir 'unattend.iso'
        New-IsoFile -SourceDir $stage -Path $unattendIso -Label 'UNATTEND'
        Remove-Item $stage -Recurse -Force

        Write-Host "Creating VM $Name in $vmDir"
        $vm = New-VM -Name $Name -Generation 2 -MemoryStartupBytes $MemoryBytes -Path $VMPath `
            -NewVHDPath (Join-Path $vmDir "$Name.vhdx") -NewVHDSizeBytes $DiskBytes -SwitchName $SwitchName
        Set-VM -VM $vm -StaticMemory -ProcessorCount $ProcessorCount -AutomaticCheckpointsEnabled $false `
            -CheckpointType Standard -AutomaticStopAction ShutDown
        Set-VMKeyProtector -VMName $Name -NewLocalKeyProtector   # Windows 11 needs a TPM
        Enable-VMTPM -VMName $Name
        Enable-VMIntegrationService -VMName $Name -Name 'Guest Service Interface'   # for Copy-VMFile
        $dvd = Add-VMDvdDrive -VMName $Name -Path $IsoPath -Passthru
        Add-VMDvdDrive -VMName $Name -Path $unattendIso
        Set-VMFirmware -VMName $Name -FirstBootDevice $dvd

        Start-VM -Name $Name
        Send-BootKeys
        Start-Process vmconnect.exe -ArgumentList 'localhost', $Name
        Write-Host "Windows is installing (~20 min). When the desktop shows 'Run dotfiles test', run: .\vm.ps1 save"
    }

    'save' {
        if (-not (Get-TestVM)) { throw "No VM named $Name." }
        if ((Get-TestVM).State -ne 'Off') { Stop-VM -Name $Name }   # clean guest shutdown
        Get-VMDvdDrive -VMName $Name | Remove-VMDvdDrive          # boot from disk from now on
        Get-VMSnapshot -VMName $Name -Name $checkpoint -ErrorAction SilentlyContinue | Remove-VMSnapshot
        Checkpoint-VM -Name $Name -SnapshotName $checkpoint
        Write-Host "Checkpoint '$checkpoint' saved. Before each test: .\vm.ps1 restore"
    }

    'restore' {
        if (-not (Get-VMSnapshot -VMName $Name -Name $checkpoint -ErrorAction SilentlyContinue)) {
            throw "No '$checkpoint' checkpoint: run '.\vm.ps1 save' after the first install."
        }
        if ((Get-TestVM).State -ne 'Off') { Stop-VM -Name $Name -TurnOff -Force }
        Restore-VMSnapshot -VMName $Name -Name $checkpoint -Confirm:$false
        Start-VM -Name $Name
        Write-Host 'Waiting for Windows to boot'
        Wait-Heartbeat
        Push-Repo
        Start-Process vmconnect.exe -ArgumentList 'localhost', $Name
        Write-Host "Ready. In the VM, double-click 'Run dotfiles test'. Afterwards: .\vm.ps1 logs"
    }

    'push' {
        if ((Get-TestVM).State -ne 'Running') { throw "VM $Name is not running." }
        Push-Repo
    }

    'logs' {
        $cred = Get-Credential -UserName $UserName -Message "Password of the VM account '$UserName'"
        $dest = Join-Path $repoRoot '.test-logs'
        New-Item -ItemType Directory -Force -Path $dest | Out-Null
        $session = New-PSSession -VMName $Name -Credential $cred   # PowerShell Direct: no network needed
        try {
            Copy-Item -FromSession $session -Path 'C:\test-logs\*' -Destination $dest -Recurse -Force
        } finally { Remove-PSSession $session }
        Get-ChildItem $dest | Sort-Object LastWriteTime | Select-Object -Last 3 | Format-Table Name, Length, LastWriteTime
    }

    'status' {
        Get-TestVM | Format-Table Name, State, CPUUsage, @{ n = 'MemoryGB'; e = { $_.MemoryAssigned / 1GB } }, Uptime
        Get-VMSnapshot -VMName $Name -ErrorAction SilentlyContinue | Format-Table Name, CreationTime
    }

    'remove' {
        if (-not (Get-TestVM)) { Write-Host "No VM named $Name."; return }
        if ($PSCmdlet.ShouldProcess("$Name and $vmDir", 'Delete VM and files')) {
            Stop-VM -Name $Name -TurnOff -Force -ErrorAction SilentlyContinue
            Remove-VM -Name $Name -Force
            if (Test-Path $vmDir) { Remove-Item $vmDir -Recurse -Force }
            Write-Host "Removed $Name."
        }
    }
}
