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
    
    $loginoutsTable | Format-Table -AutoSize
} else {
    Write-Host "No Winlogon events found!"
}