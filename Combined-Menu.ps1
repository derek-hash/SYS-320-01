<# ******************************
     Combined-Menu.ps1
     Integrated Security and System Management Menu
****************************** #>

# Import required scripts using dot notation
# Update these paths to match where your script files are located
. (Join-Path $PSScriptRoot "Event-Logs.ps1")
. (Join-Path $PSScriptRoot "String-Helper.ps1")
. (Join-Path $PSScriptRoot "Users.ps1")
. (Join-Path $PSScriptRoot "ApacheLogs.ps1")
. (Join-Path $PSScriptRoot "ProcessManagement.ps1")

Clear-Host

# Display the menu
function Show-Menu {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  Security & System Management Menu" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Display last 10 Apache logs" -ForegroundColor Yellow
    Write-Host "2. Display last 10 failed logins for all users" -ForegroundColor Yellow
    Write-Host "3. Display at risk users" -ForegroundColor Yellow
    Write-Host "4. Start Chrome and navigate to champlain.edu" -ForegroundColor Yellow
    Write-Host "5. Exit" -ForegroundColor Red
    Write-Host ""
}

# Main menu loop
$running = $true

while($running){
    
    Show-Menu
    $choice = Read-Host "Please select an option (1-5)"
    
    # Validate input is a number between 1-5
    if($choice -notmatch '^[1-5]$'){
        Write-Host "`nInvalid input! Please enter a number between 1 and 5." -ForegroundColor Red
        Write-Host "Press any key to continue..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Clear-Host
        continue
    }
    
    # Convert to integer for switch statement
    $choice = [int]$choice
    
    switch($choice){
        
        1 {
            # Display last 10 Apache logs
            Write-Host "`n========================================" -ForegroundColor Green
            Write-Host "  Last 10 Apache Logs" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            
            try {
                $apacheLogs = ApacheLogs1
                
                if($apacheLogs -and $apacheLogs.Count -gt 0){
                    $lastTen = $apacheLogs | Select-Object -Last 10
                    Write-Host ($lastTen | Format-Table -AutoSize | Out-String)
                    Write-Host "Successfully displayed last 10 Apache logs." -ForegroundColor Green
                }
                else{
                    Write-Host "No Apache logs found or unable to retrieve logs." -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "Error retrieving Apache logs: $_" -ForegroundColor Red
            }
            
            Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Clear-Host
        }
        
        2 {
            # Display last 10 failed logins for all users
            Write-Host "`n========================================" -ForegroundColor Green
            Write-Host "  Last 10 Failed Login Attempts" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            
            try {
                # Get failed logins for the last 30 days
                $failedLogins = getFailedLogins 30
                
                if($failedLogins -and $failedLogins.Count -gt 0){
                    $lastTen = $failedLogins | Select-Object -Last 10
                    Write-Host ($lastTen | Format-Table -AutoSize | Out-String)
                    Write-Host "Successfully displayed last 10 failed login attempts." -ForegroundColor Green
                }
                else{
                    Write-Host "No failed login attempts found in the last 30 days." -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "Error retrieving failed logins: $_" -ForegroundColor Red
                Write-Host "Make sure you are running PowerShell as Administrator." -ForegroundColor Yellow
            }
            
            Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Clear-Host
        }
        
        3 {
            # Display at risk users
            Write-Host "`n========================================" -ForegroundColor Green
            Write-Host "  At Risk Users Analysis" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            
            $days = Read-Host "Enter number of days to look back (default: 30)"
            
            if([string]::IsNullOrWhiteSpace($days) -or $days -notmatch '^\d+$'){
                $days = 30
                Write-Host "Using default value: 30 days" -ForegroundColor Yellow
            }
            
            try {
                $failedLogins = getFailedLogins ([int]$days)
                
                if($failedLogins -and $failedLogins.Count -gt 0){
                    # Group by user and count failed logins
                    $atRiskUsers = $failedLogins | Group-Object -Property User | Where-Object { $_.Count -gt 10 } | Select-Object Name, Count | Sort-Object Count -Descending
                    
                    if($atRiskUsers -and $atRiskUsers.Count -gt 0){
                        Write-Host "`nAt Risk Users (More than 10 failed logins in the last $days days):" -ForegroundColor Red
                        Write-Host ($atRiskUsers | Format-Table -Property Name, Count -AutoSize | Out-String)
                        Write-Host "Total at risk users: $($atRiskUsers.Count)" -ForegroundColor Red
                    }
                    else{
                        Write-Host "`nNo at risk users found in the last $days days." -ForegroundColor Green
                        Write-Host "All users have 10 or fewer failed login attempts." -ForegroundColor Green
                    }
                }
                else{
                    Write-Host "`nNo failed login attempts found in the last $days days." -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "Error analyzing at risk users: $_" -ForegroundColor Red
                Write-Host "Make sure you are running PowerShell as Administrator." -ForegroundColor Yellow
            }
            
            Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Clear-Host
        }
        
        4 {
            # Start Chrome and navigate to champlain.edu
            Write-Host "`n========================================" -ForegroundColor Green
            Write-Host "  Chrome Browser Management" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            
            try {
                # Check if Chrome is already running
                $chromeProcess = Get-Process -Name "chrome" -ErrorAction SilentlyContinue
                
                if($chromeProcess){
                    Write-Host "Chrome is already running." -ForegroundColor Yellow
                    Write-Host "Found $($chromeProcess.Count) Chrome process(es)." -ForegroundColor Yellow
                }
                else{
                    Write-Host "Chrome is not running. Starting Chrome..." -ForegroundColor Green
                    
                    # Common Chrome installation paths
                    $chromePaths = @(
                        "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
                        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
                        "${env:LocalAppData}\Google\Chrome\Application\chrome.exe"
                    )
                    
                    $chromeFound = $false
                    foreach($path in $chromePaths){
                        if(Test-Path $path){
                            Start-Process $path "https://www.champlain.edu"
                            Write-Host "Chrome started successfully and navigated to champlain.edu" -ForegroundColor Green
                            $chromeFound = $true
                            break
                        }
                    }
                    
                    if(-not $chromeFound){
                        Write-Host "Chrome executable not found in common locations." -ForegroundColor Red
                        Write-Host "Please ensure Google Chrome is installed." -ForegroundColor Yellow
                    }
                }
            }
            catch {
                Write-Host "Error managing Chrome: $_" -ForegroundColor Red
            }
            
            Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Clear-Host
        }
        
        5 {
            # Exit
            Write-Host "`n========================================" -ForegroundColor Green
            Write-Host "  Exiting Program" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "Thank you for using the Security & System Management Menu!" -ForegroundColor Cyan
            Write-Host "Goodbye!`n" -ForegroundColor Cyan
            $running = $false
        }
    }
}