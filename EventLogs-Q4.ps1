function Get-LoginLogoffEvents {
    param(
        [int]$Days
    )
    
    # Get Winlogon events - use a large number to ensure we get enough
    $allEvents = Get-EventLog System -Source Microsoft-Windows-Winlogon -Newest 5000
    
    # Filter by date
    $loginouts = $allEvents | Where-Object {$_.TimeGenerated -gt (Get-Date).AddDays(-$Days)}
    
    # Check if we got anything
    Write-Host "Found $($loginouts.Count) Winlogon events in the last $Days days"
    
    # Build the table
    $loginoutsTable = @()
    
    if($loginouts.Count -gt 0) {
        foreach($log in $loginouts) {
            $event = ""
            if($log.InstanceId -eq 7001) {$event = "Logon"}
            if($log.InstanceId -eq 7002) {$event = "Logoff"}
            
            # Get SID from ReplacementStrings
            $sid = $log.ReplacementStrings[1]
            
            # Convert SID to username
            try {
                $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid)
                $user = $objSID.Translate([System.Security.Principal.NTAccount]).Value
            } catch {
                $user = $sid  # If conversion fails, keep the SID
            }
            
            $loginoutsTable += [pscustomobject]@{
                "Time" = $log.TimeGenerated
                "Id" = $log.InstanceID
                "Event" = $event
                "User" = $user
            }
        }
    }
    
    # Return the table
    return $loginoutsTable
}

# Call the function with 24 days as parameter and print results
$results = Get-LoginLogoffEvents -Days 180
$results | Format-Table -AutoSize