function Get-ApacheLogs {
    param(
        [string]$Page,        
        [string]$HTTPCode,    
        [string]$Browser      
    )
    
    # Get all matching lines from the log
    $matchingLogs = Get-Content "C:\xampp\apache\logs\access.log" | Select-String -Pattern $HTTPCode
    
    # Further filter if Page is provided
    if ($Page) {
        $matchingLogs = $matchingLogs | Where-Object { $_ -match $Page }
    }
    
    # Further filter if Browser is provided
    if ($Browser) {
        $matchingLogs = $matchingLogs | Where-Object { $_ -match $Browser }
    }
    
    # Extract unique IP addresses
    $ips = $matchingLogs | ForEach-Object {
        $line = $_.ToString()
        ($line -split ' ')[0]
    } | Select-Object -Unique
    
    return $ips
}
