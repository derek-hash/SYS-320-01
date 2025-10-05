<# ******************************
     Main.ps1
****************************** #>
. (Join-Path $PSScriptRoot Users.ps1)
. (Join-Path $PSScriptRoot Event-Logs.ps1)
. (Join-Path $PSScriptRoot String-Helper.ps1)

clear

$Prompt = "`n"
$Prompt += "Please choose your operation:`n"
$Prompt += "1 - List Enabled Users`n"
$Prompt += "2 - List Disabled Users`n"
$Prompt += "3 - Create a User`n"
$Prompt += "4 - Remove a User`n"
$Prompt += "5 - Enable a User`n"
$Prompt += "6 - Disable a User`n"
$Prompt += "7 - Get Log-In Logs`n"
$Prompt += "8 - Get Failed Log-In Logs`n"
$Prompt += "9 - List at Risk Users`n"
$Prompt += "10 - Exit`n"



$operation = $true

while($operation){

    
    Write-Host $Prompt | Out-String
    $choice = Read-Host 


    if($choice -eq 10){
        Write-Host "Goodbye" | Out-String
        exit
        $operation = $false 
    }

    elseif($choice -eq 1){
        $enabledUsers = getEnabledUsers
        Write-Host ($enabledUsers | Format-Table | Out-String)
    }

    elseif($choice -eq 2){
        $notEnabledUsers = getNotEnabledUsers
        Write-Host ($notEnabledUsers | Format-Table | Out-String)
    }


    # Create a user
    elseif($choice -eq 3){ 

        $name = Read-Host -Prompt "Please enter the username for the new user"
        $password = Read-Host -AsSecureString -Prompt "Please enter the password for the new user"

        # Check if user already exists
        if(checkUser $name){
            Write-Host "User '$name' already exists. Please choose a different username." -ForegroundColor Red | Out-String
            continue
        }

        # Convert SecureString to plain text for password validation
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
        $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

        # Check if password meets requirements
        if(-not (checkPassword $plainPassword)){
            Write-Host "Password does not meet the requirements:" -ForegroundColor Red | Out-String
            Write-Host "  - Must be at least 6 characters long" -ForegroundColor Yellow | Out-String
            Write-Host "  - Must contain at least 1 letter" -ForegroundColor Yellow | Out-String
            Write-Host "  - Must contain at least 1 number" -ForegroundColor Yellow | Out-String
            Write-Host "  - Must contain at least 1 special character" -ForegroundColor Yellow | Out-String
            continue
        }

        createAUser $name $password

        Write-Host "User: $name is created." | Out-String
    }


    # Remove a user
    elseif($choice -eq 4){

        $name = Read-Host -Prompt "Please enter the username for the user to be removed"

        # Check if user exists
        if(-not (checkUser $name)){
            Write-Host "User '$name' does not exist." -ForegroundColor Red | Out-String
            continue
        }

        removeAUser $name

        Write-Host "User: $name Removed." | Out-String
    }


    # Enable a user
    elseif($choice -eq 5){


        $name = Read-Host -Prompt "Please enter the username for the user to be enabled"

        # Check if user exists
        if(-not (checkUser $name)){
            Write-Host "User '$name' does not exist." -ForegroundColor Red | Out-String
            continue
        }

        enableAUser $name

        Write-Host "User: $name Enabled." | Out-String
    }


    # Disable a user
    elseif($choice -eq 6){

        $name = Read-Host -Prompt "Please enter the username for the user to be disabled"

        # Check if user exists
        if(-not (checkUser $name)){
            Write-Host "User '$name' does not exist." -ForegroundColor Red | Out-String
            continue
        }

        disableAUser $name

        Write-Host "User: $name Disabled." | Out-String
    }


    elseif($choice -eq 7){

        $name = Read-Host -Prompt "Please enter the username for the user logs"

        # Check if user exists
        if(-not (checkUser $name)){
            Write-Host "User '$name' does not exist." -ForegroundColor Red | Out-String
            continue
        }

        # Get number of days from user
        $days = Read-Host -Prompt "Please enter the number of days to look back"
        
        # Validate that days is a number
        if($days -match '^\d+$'){
            $userLogins = getLogInAndOffs ([int]$days)
            Write-Host ($userLogins | Where-Object { $_.User -ilike "*$name"} | Format-Table | Out-String)
        }
        else{
            Write-Host "Invalid input. Please enter a valid number." -ForegroundColor Red | Out-String
        }
    }


    elseif($choice -eq 8){

        $name = Read-Host -Prompt "Please enter the username for the user's failed login logs"

        # Check if user exists
        if(-not (checkUser $name)){
            Write-Host "User '$name' does not exist." -ForegroundColor Red | Out-String
            continue
        }

        # Get number of days from user
        $days = Read-Host -Prompt "Please enter the number of days to look back"
        
        # Validate that days is a number
        if($days -match '^\d+$'){
            $userLogins = getFailedLogins ([int]$days)
            Write-Host ($userLogins | Where-Object { $_.User -ilike "*$name"} | Format-Table | Out-String)
        }
        else{
            Write-Host "Invalid input. Please enter a valid number." -ForegroundColor Red | Out-String
        }
    }


    # List at Risk Users - users with more than 10 failed logins
    elseif($choice -eq 9){

        $days = Read-Host -Prompt "Please enter the number of days to look back"
        
        # Validate that days is a number
        if($days -match '^\d+$'){
            $failedLogins = getFailedLogins ([int]$days)
            
            # Group by user and count failed logins
            $atRiskUsers = $failedLogins | Group-Object -Property User | Where-Object { $_.Count -gt 10 } | Select-Object Name, Count
            
            if($atRiskUsers.Count -gt 0){
                Write-Host "`nAt Risk Users (More than 10 failed logins in the last $days days):" -ForegroundColor Red | Out-String
                Write-Host ($atRiskUsers | Format-Table -Property Name, Count | Out-String)
            }
            else{
                Write-Host "`nNo at risk users found in the last $days days." -ForegroundColor Green | Out-String
            }
        }
        else{
            Write-Host "Invalid input. Please enter a valid number." -ForegroundColor Red | Out-String
        }
    }

    # Handle invalid input
    else{
        Write-Host "Invalid choice. Please select a number between 1 and 10." -ForegroundColor Red | Out-String
    }
    

}