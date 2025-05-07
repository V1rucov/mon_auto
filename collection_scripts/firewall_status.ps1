$firewallProfiles = Get-NetFirewallProfile

$disabledProfiles = @()
$enabledProfiles = @()

foreach ($profile in $firewallProfiles) {
    $profileName = $profile.Name
    $isEnabled = $profile.Enabled

    if (-not $isEnabled) {
        $disabledProfiles += $profileName
    } else {
        $enabledProfiles += $profileName
    }
}

Write-Output "=== Windows Firewall Status ==="
Write-Output "Enabled profiles  : $($enabledProfiles -join ', ')"
Write-Output "Disabled profiles : $($disabledProfiles -join ', ')"

if ($disabledProfiles.Count -gt 0) {
    Write-Warning "Firewall is PARTIALLY DISABLED! The following profiles are off: $($disabledProfiles -join ', ')"
} else {
    Write-Output 0
}
