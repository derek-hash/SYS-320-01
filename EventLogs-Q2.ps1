# First, let's see if any Winlogon events exist at all
$loginouts = Get-EventLog System -Source Microsoft-Windows-Winlogon -Newest 100

# Check if we got anything
Write-Host "Found $($loginouts.Count) Winlogon events"

# If we have events, show the first one to see what data is available
if($loginouts.Count -gt 0) {
    Write-Host "`nFirst event details:"
    $loginouts[0] | Format-List TimeGenerated, InstanceId, ReplacementStrings
    
    # Now build the table
    $loginoutsTable = @()
    
    foreach($log in $loginouts) {
        $event = ""
        if($log.InstanceId -eq 7001) {$event = "Logon"}
        if($log.InstanceId -eq 7002) {$event = "Logoff"}
        
        $user = $log.ReplacementStrings[1]
        
        $loginoutsTable += [pscustomobject]@{
            "Time" = $log.TimeGenerated
            "Id" = $log.InstanceID
            "Event" = $event
            "User" = $user
        }
    }
    
    $loginoutsTable | Format-Table -AutoSize
} else {
    Write-Host "No Winlogon events found!"
}