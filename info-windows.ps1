param(
    [int]$MaxEvents = 10
)

Write-Output "==== Reference ===="
Get-Date
$env:COMPUTERNAME
$env:USERNAME

Write-Output "`n==== Local Users ===="
$users = Get-LocalUser | Sort-Object Name
$users | Select-Object Name, Enabled, LastLogon, PasswordLastSet, PasswordNeverExpires

Write-Output "`n==== High Privilege Membership (Administrators) ===="
$adminMembers = @()
try {
    $adminMembers = Get-LocalGroupMember -Group "Administrators" | Select-Object -ExpandProperty Name
    if ($adminMembers.Count -eq 0) { Write-Output "(none)" } else { $adminMembers }
} catch {
    Write-Output "(unable to read Administrators group members)"
}

Write-Output "`n==== User Summary ===="
foreach ($user in $users) {
    $isAdmin = $false
    foreach ($m in $adminMembers) {
        if ($m -match "\\$($user.Name)$" -or $m -eq $user.Name) { $isAdmin = $true; break }
    }

    Write-Output "User: $($user.Name)"
    Write-Output "  Enabled: $($user.Enabled)"
    Write-Output "  LastLogon: $($user.LastLogon)"
    Write-Output "  PasswordLastSet: $($user.PasswordLastSet)"
    Write-Output "  PasswordNeverExpires: $($user.PasswordNeverExpires)"
    Write-Output "  HighPriv(Administrators): $isAdmin"
}

Write-Output "`n==== Recent Successful Logons (Event ID 4624) ===="
try {
    $events = Get-WinEvent -FilterHashtable @{ LogName='Security'; Id=4624 } -MaxEvents $MaxEvents -ErrorAction Stop
    foreach ($e in $events) {
        $xml = [xml]$e.ToXml()
        $targetUser = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetUserName' } | Select-Object -First 1).'#text'
        $logonType = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq 'LogonType' } | Select-Object -First 1).'#text'
        "{0} | User={1} | LogonType={2}" -f $e.TimeCreated, $targetUser, $logonType
    }
} catch {
    Write-Output "(unable to read Security event log; run elevated)"
}
