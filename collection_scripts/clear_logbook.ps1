$timeThreshold = (Get-Date).AddMinutes(-1)
$clear_logbook = Get-WinEvent -FilterHashtable @{
    LogName = "Security";
    ID = 1102;
    StartTime = $timeThreshold
} -ErrorAction SilentlyContinue

if ($clear_logbook) { 
    Write-Output "Security log was cleared on $(hostname) at $($clear_logbook.TimeCreated)"
} 
else { Write-Output 0;}