$timeThreshold = (Get-Date).AddMinutes(-1)

$events = Get-WinEvent -FilterHashtable @{
    LogName = "Security";
    ID = 4719;
    StartTime = $timeThreshold
} -ErrorAction SilentlyContinue

if ($events) {
    foreach ($event in $events) {
        Write-Host "Audit policy changed: TIME: $($event.TimeCreated), USR: $($event.Properties[1].Value) on $(hostname)"
    }
}
else {Write-Host "1"}
