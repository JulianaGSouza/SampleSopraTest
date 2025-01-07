if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script needs to be run as an administrator. Restarting with elevated privileges..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    Start-Process PowerShell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Check for virtualization
function Check-Virtualization {
    Write-Host "Checking if virtualization is enabled..." -ForegroundColor Green

    # Check for hypervisor presence
    $hypervisorDetected = (Get-ComputerInfo).HypervisorPresent

    # Check virtualization support via registry
    $featureSet = (Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0").FeatureSet -band 0x10000000

    # Check via Win32_ComputerSystem (fallback)
    $vmCheck = (Get-WmiObject -Class Win32_ComputerSystem).HypervisorPresent

    if ($hypervisorDetected -or $featureSet -ne 0 -or $vmCheck) {
        Write-Host "Virtualization is enabled." -ForegroundColor Green
        return $true
    } else {
        Write-Host "Virtualization is not enabled in your BIOS." -ForegroundColor Red
        Write-Host "Please enable virtualization in your BIOS settings." -ForegroundColor Yellow
        Write-Host "Refer to this guide for help: https://learn.microsoft.com/en-us/windows/wsl/install" -ForegroundColor Cyan
        return $false
    }
}

# Perform virtualization check
if (-not (Check-Virtualization)) {
    exit
}

# Enable required Windows features via DISM
Write-Host "Enabling required Windows features for WSL..." -ForegroundColor Green
try {
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    Write-Host "Windows features enabled successfully." -ForegroundColor Green
} catch {
    Write-Host "Failed to enable required Windows features." -ForegroundColor Red
    exit
}

# Continue with the rest of the WSL setup...

Write-Host "Checking if WSL is installed..." -ForegroundColor Green
if (!(wsl --status 2>$null)) {
    Write-Host "Installing WSL..." -ForegroundColor Green
    try {
        wsl --install
    } catch {
        Write-Host "WSL installation encountered an issue." -ForegroundColor Yellow
    }
} else {
    Write-Host "WSL is already installed." -ForegroundColor Yellow
}

Write-Host "Setting WSL default version to 2..." -ForegroundColor Green
try {
    wsl --set-default-version 2
} catch {
    Write-Host "Failed to set WSL default version: It may already be configured." -ForegroundColor Yellow
}

Write-Host "Checking if Ubuntu is installed..." -ForegroundColor Green
$UbuntuInstalled = wsl -l -q | Select-String -Pattern "Ubuntu"

if (!$UbuntuInstalled) {
    Write-Host "Installing Ubuntu distribution for WSL..." -ForegroundColor Green
    try {
        wsl --install -d Ubuntu
    } catch {
        Write-Host "Ubuntu installation encountered an issue." -ForegroundColor Yellow
    }
} else {
    Write-Host "Ubuntu is already installed. Skipping installation." -ForegroundColor Yellow
}

# Function to check if a reboot is required
function Is-RebootRequired {
    $keys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations"
    )

    foreach ($key in $keys) {
        if (Test-Path $key) {
            return $true
        }
    }

    return $false
}

# reboot check
if (Is-RebootRequired) {
    Write-Host "A system reboot is required to complete the setup." -ForegroundColor Yellow
    $userInput = Read-Host "Do you want to reboot now? (y/n)"
    if ($userInput -eq "y" -or $userInput -eq "Y") {
        Write-Host "Rebooting the system..." -ForegroundColor Green
        Restart-Computer
    } else {
        Write-Host "Reboot skipped. Please remember to reboot later to apply changes." -ForegroundColor Cyan
    }
} else {
    Write-Host "No reboot is required. Setup completed successfully." -ForegroundColor Green
}

Write-Host "Press Enter to exit..." -ForegroundColor Cyan
Read-Host