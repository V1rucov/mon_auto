$timeThreshold = (Get-Date).AddMinutes(-1)

$events = Get-WinEvent -FilterHashtable @{
    LogName = "Security";
    ID = 4624;
    StartTime = $timeThreshold
} -ErrorAction SilentlyContinue

$filteredEvents = $events | Where-Object {
    $_.Properties[8].Value -eq 10 -or $_.Properties[8].Value -eq 7
}

if ($filteredEvents) {
    Write-Host "Interactive logon (or RDP) detected:"
    foreach ($event in $filteredEvents) {
        Write-Host "----------------------------------"
        Write-Host "TIME: $($event.TimeCreated)"
        Write-Host "USR: $($event.Properties[5].Value)"
        Write-Host "SRC: $($event.Properties[18].Value)"
        Write-Host "----------------------------------"
    }
} 
else {Write-Host "0"}
