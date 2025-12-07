function Get-StartShutdownEvents {
    param(
        [int]$Days
    )
    
    # Get startup events (EventId 6013) and shutdown events (EventId 1074)
    $allEvents = Get-EventLog System -Newest 5000 | 
                 Where-Object {($_.EventId -eq 6013 -or $_.EventId -eq 1074) -and 
                               $_.TimeGenerated -gt (Get-Date).AddDays(-$Days)}
    
    # Check if we got anything
    Write-Host "Found $($allEvents.Count) Start/Shutdown events in the last $Days days"
    
    # Build the table
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
    
    # Return the table
    return $eventsTable
}

# Call the function with 180 days as parameter and print results
$results = Get-StartShutdownEvents -Days 180
$results | Format-Table -AutoSize