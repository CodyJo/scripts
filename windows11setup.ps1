# List of packages to install via Chocolatey
$packages = @(
    "7zip", "awscli", "curl", "ditto", "docker-desktop", "gcloudsdk", "git",
    "lastpass", "notepadplusplus", "pdk", "powershell-core", "python",
    "ruby", "sharex", "spotify", "sysinternals", "terraform", "vlc", "vscode"
)

# Optimized and Organized PowerShell Script
# Windows Updates are moved to the end for efficiency.

# Function to create a scheduled task to resume the script after reboot
function Create-ScheduledTask {
    Write-Host "Creating scheduled task to resume script after reboot..."
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -File `"$PSScriptRoot\newinstallinstall4cody.ps1`""
    $Trigger = New-ScheduledTaskTrigger -AtStartup
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    $Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -TaskName "ResumeScriptAfterReboot" -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal
}

# Function to remove the scheduled task
function Remove-ScheduledTask {
    Write-Host "Removing scheduled task..."
    Unregister-ScheduledTask -TaskName "ResumeScriptAfterReboot" -Confirm:$false
}

# Function to handle Windows updates
function Update-Windows {
    Write-Host "Checking for and installing Windows updates..."
    try {
        Install-WindowsUpdate -AcceptAll -IgnoreReboot
        Write-Host "Windows updates installed successfully. A reboot may be required." -ForegroundColor Green
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "Failed to install Windows updates: $ErrorMessage" -ForegroundColor Red
    }

    # Check if a reboot is required
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") {
        Write-Host "A reboot is required to complete updates. Rebooting now..." -ForegroundColor Yellow
        Restart-Computer -Force
    }
}

# Main script execution
try {
    # Create the scheduled task
    Create-ScheduledTask

    # Set Security Protocol
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Install IIS and IISAdministration module
    Write-Host "Installing IIS and IISAdministration module..."
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools
    Install-Module -Name IISAdministration -Force -AllowClobber

    # Disable IE Enhanced Security Configuration (ESC)
    Write-Host "Disabling IE Enhanced Security Configuration..."
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
    Stop-Process -Name Explorer -Force
    Write-Host "IE ESC has been disabled." -ForegroundColor Green

    # Allow downloads in IE
    Write-Host "Enabling downloads in IE..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" -Name "1803" -Value 0

    # Download and install Chocolatey
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "Chocolatey installed successfully." -ForegroundColor Green

    # Disable Remote Desktop
    Write-Host "Disabling Remote Desktop..."
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1

    # Optimize power settings for max performance
    Write-Host "Optimizing power settings..."
    powercfg -change -standby-timeout-ac 0
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -disk-timeout-ac 0

    # Configure Firewall
    Write-Host "Configuring firewall settings..."
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

    # Create System Restore Point
    Write-Host "Creating a system restore point..."
    Checkpoint-Computer -Description "Post-Setup Restore Point" -RestorePointType "MODIFY_SETTINGS"

    # Set Environment Variables
    Write-Host "Setting environment variables..."
    [System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-11", [System.EnvironmentVariableTarget]::Machine)
    [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Java\jdk-11\bin", [System.EnvironmentVariableTarget]::Machine)

    # Disable unnecessary services
    Write-Host "Disabling unnecessary services..."
    Get-Service -Name "DiagTrack", "dmwappushservice" | Set-Service -StartupType Disabled

    # Install additional packages via Chocolatey
    Write-Host "Installing packages via Chocolatey..."
    foreach ($package in $packages) {
        Write-Host "Installing $package..."
        choco install $package -y --ignore-checksums
    }

    # Verify installations
    Write-Host "Verifying installed Chocolatey packages..."
    choco list --localonly

    Write-Host "Core setup tasks completed successfully. Starting Windows Update..." -ForegroundColor Yellow

    # Perform Windows Update as the last step
    Update-Windows

    Write-Host "Script completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "An error occurred: $_" -ForegroundColor Red
}
finally {
    # Remove the scheduled task
    Remove-ScheduledTask
}
