# Dedupe the User PATH and warn before it gets long enough for Explorer to drop it.
#
# When Machine + User PATH passes ~4095 chars, Explorer ignores the whole User
# PATH the next time it reloads the environment (any installer that touches PATH
# triggers this). The full PATH still works until then because sign-in builds it
# differently, so the breakage shows up later as "every tool vanished" in new
# terminals. Keep CLI tools on scoop (one shims entry) to stay well below it.
function Optimize-UserPath {
  $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
  $raw = $key.GetValue('Path', '', 'DoNotExpandEnvironmentNames')
  $seen = @{}
  $entries = foreach ($entry in ($raw -split ';')) {
    if (-not $entry) { continue }
    $normalized = ($entry -replace '\\\.\\', '\').TrimEnd('\')
    $id = [Environment]::ExpandEnvironmentVariables($normalized).ToLowerInvariant()
    if ($seen.ContainsKey($id)) { continue }
    $seen[$id] = $true
    $normalized
  }
  $clean = $entries -join ';'
  if ($clean -ne $raw) {
    $key.SetValue('Path', $clean, [Microsoft.Win32.RegistryValueKind]::ExpandString)
    Write-Host "User PATH deduplicated ($($raw.Length) -> $($clean.Length) chars)"
  }
  $key.Close()

  $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  $total = $machine.Length + 1 + [Environment]::ExpandEnvironmentVariables($clean).Length
  if ($total -gt 3800) {
    Write-Warning ("Machine + User PATH is $total chars. Above ~4095, Explorer drops the User PATH on the next environment refresh. " +
      'Move per-package PATH entries (user-scope WinGet portables especially) to scoop.')
  } else {
    Write-Host "PATH length OK ($total / ~4095 chars)"
  }
}
