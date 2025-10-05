<# ******************************
     ApacheLogs.ps1
     Parse and display Apache log files
****************************** #>

<# ******************************
   Function: ApacheLogs1
   Purpose: Parse Apache access logs and return structured data
   Output: Array of custom objects with log data
****************************** #>
function ApacheLogs1 {
    
    # Path to Apache log file - UPDATE THIS PATH to match your Apache log location
    # Common paths:
    # Windows XAMPP: "C:\xampp\apache\logs\access.log"
    # Linux: "/var/log/apache2/access.log"
    # macOS: "/usr/local/var/log/httpd/access_log"
    
    $logPath = "C:\xampp\apache\logs\access.log"
    
    # Check if log file exists
    if(-not (Test-Path $logPath)){
        Write-Host "Apache log file not found at: $logPath" -ForegroundColor Red
        Write-Host "Please update the log path in ApacheLogs.ps1" -ForegroundColor Yellow
        return $null
    }
    
    # Read the log file
    $logContent = Get-Content $logPath
    
    $parsedLogs = @()
    
    # Apache log format (Common Log Format):
    # IP - - [datetime] "METHOD /path HTTP/version" status size
    $pattern = '^(\S+) \S+ \S+ \[([^\]]+)\] "(\S+) (\S+) \S+" (\d+) (\S+)'
    
    foreach($line in $logContent){
        if($line -match $pattern){
            $parsedLogs += [PSCustomObject]@{
                IP = $matches[1]
                DateTime = $matches[2]
                Method = $matches[3]
                Resource = $matches[4]
                Status = $matches[5]
                Size = $matches[6]
            }
        }
    }
    
    return $parsedLogs
}