function Get-LoginLogoffEvents {
    param(
        [int]$Days
    )
    
    $allEvents = Get-EventLog System -Source Microsoft-Windows-Winlogon -Newest 5000
    $loginouts = $allEvents | Where-Object {$_.TimeGenerated -gt (Get-Date).AddDays(-$Days)}
    
    Write-Host "Found $($loginouts.Count) Winlogon events in the last $Days days"
    
    $loginoutsTable = @()
    
    if($loginouts.Count -gt 0) {
        foreach($log in $loginouts) {
            $event = ""
            if($log.InstanceId -eq 7001) {$event = "Logon"}
            if($log.InstanceId -eq 7002) {$event = "Logoff"}
            
            $sid = $log.ReplacementStrings[1]
            
            try {
                $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid)
                $user = $objSID.Translate([System.Security.Principal.NTAccount]).Value
            } catch {
                $user = $sid
            }
            
            $loginoutsTable += [pscustomobject]@{
                "Time" = $log.TimeGenerated
                "Id" = $log.InstanceID
                "Event" = $event
                "User" = $user
            }
        }
    }
    
    return $loginoutsTable
}

function Get-StartShutdownEvents {
    param(
        [int]$Days
    )
    
    $allEvents = Get-EventLog System -Newest 5000 | 
                 Where-Object {($_.EventId -eq 6013 -or $_.EventId -eq 1074) -and 
                               $_.TimeGenerated -gt (Get-Date).AddDays(-$Days)}
    
    Write-Host "Found $($allEvents.Count) Start/Shutdown events in the last $Days days"
    
    $eventsTable = @()
    
    if($allEvents.Count -gt 0) {
        foreach($log in $allEvents) {
            $event = ""
            if($log.EventId -eq 6013) {$event = "Startup"}
            if($log.EventId -eq 1074) {$event = "Shutdown"}
            
            $eventsTable += [pscustomobject]@{
                "Time" = $log.TimeGenerated
                "Id" = $log.EventID
                "Event" = $event
                "User" = "System"
            }
        }
    }
    
    return $eventsTable
}