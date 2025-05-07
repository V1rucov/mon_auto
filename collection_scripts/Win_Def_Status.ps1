$defenderStatus = Get-MpComputerStatus | Select-Object AMServiceEnabled, AntispywareEnabled, 
RealTimeProtectionEnabled, AntivirusEnabled, NISSignatureLastUpdated

$disabledComponents = @{}

if (-not $defenderStatus.AMServiceEnabled) {
    $disabledComponents["AMServiceEnabled"] = "Core Defender service is disabled"
}
if (-not $defenderStatus.AntispywareEnabled) {
    $disabledComponents["AntispywareEnabled"] = "Antispyware component is disabled"
}
if (-not $defenderStatus.RealTimeProtectionEnabled) {
    $disabledComponents["RealTimeProtectionEnabled"] = "Real-time protection is disabled"
}
if (-not $defenderStatus.AntivirusEnabled) {
    $disabledComponents["AntivirusEnabled"] = "Antivirus component is disabled"
}

if ($disabledComponents.Count -gt 0) {
    Write-Output "WinDefender status: some components are DISABLED."
    foreach ($key in $disabledComponents.Keys) {
        Write-Output "$key => $($disabledComponents[$key])"
    }
} else {
    Write-Output 0
}
