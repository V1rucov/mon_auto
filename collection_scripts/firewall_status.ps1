$firewallStatus = Get-NetFirewallProfile | Select-Object -ExpandProperty Enabled
$disabledCount = ($firewallStatus | Where-Object {$_ -eq $false}).Count
$disabledCount
