$defenderStatus = Get-MpPreference

if ($defenderStatus.DisableRealtimeMonitoring -eq $true) {
    Write-Output "WinDefender RTM was disabled on $(hostname) at $($clear_logbook.TimeCreated)" 
}
else {Write-Output 0}
