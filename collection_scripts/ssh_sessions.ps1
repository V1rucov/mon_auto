$ssh_sessions = (netstat -an | Select-String ":22" | Select-String "ESTABLISHED").Count
$ssh_sessions
