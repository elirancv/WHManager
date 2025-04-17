# Script to install WinGet package manager
# This script installs the WinGet PowerShell module and bootstraps the package manager

# Set progress preference to silently continue to reduce output noise
$progressPreference = 'silentlyContinue'

try {
    Write-Host "Starting WinGet installation process..." -ForegroundColor Green

    # Install NuGet package provider if not present
    Write-Host "Installing NuGet package provider..." -ForegroundColor Yellow
    $nugetJob = Start-Job -ScriptBlock {
        Install-PackageProvider -Name NuGet -Force
    }
    Wait-Job $nugetJob -Timeout 30 | Out-Null
    if ($nugetJob.State -eq "Running") {
        Stop-Job $nugetJob
        throw "NuGet package provider installation timed out"
    }
    Receive-Job $nugetJob | Out-Null

    # Check if WinGet module is already installed
    $wingetModule = Get-Module -ListAvailable -Name Microsoft.WinGet.Client
    if (-not $wingetModule) {
        Write-Host "Installing WinGet PowerShell module from PSGallery..." -ForegroundColor Yellow
        $moduleJob = Start-Job -ScriptBlock {
            Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery
        }
        Wait-Job $moduleJob -Timeout 30 | Out-Null
        if ($moduleJob.State -eq "Running") {
            Stop-Job $moduleJob
            throw "WinGet module installation timed out"
        }
        Receive-Job $moduleJob | Out-Null
    } else {
        Write-Host "WinGet PowerShell module is already installed." -ForegroundColor Yellow
    }

    # Bootstrap WinGet package manager
    Write-Host "Bootstrapping WinGet package manager..." -ForegroundColor Yellow
    $repairJob = Start-Job -ScriptBlock {
        Repair-WinGetPackageManager
    }
    Wait-Job $repairJob -Timeout 30 | Out-Null
    if ($repairJob.State -eq "Running") {
        Stop-Job $repairJob
        throw "WinGet package manager repair timed out"
    }
    Receive-Job $repairJob | Out-Null

    # Set region to US (required for Microsoft Store)
    Write-Host "Setting region to US..." -ForegroundColor Yellow
    $region = Get-WinSystemLocale
    if ($region.Name -ne "en-US") {
        Set-WinSystemLocale -SystemLocale "en-US" -ErrorAction Stop
        Write-Host "System locale has been changed. A system restart may be required." -ForegroundColor Yellow
    }

    # Configure winget sources
    Write-Host "Configuring package sources..." -ForegroundColor Yellow
    
    # Remove existing sources if they exist
    $existingSources = winget source list
    if ($existingSources -match "winget") {
        Write-Host "Removing existing winget source..." -ForegroundColor Yellow
        winget source remove -n winget
    }
    if ($existingSources -match "msstore") {
        Write-Host "Removing existing msstore source..." -ForegroundColor Yellow
        winget source remove -n msstore
    }

    # Add winget source
    Write-Host "Adding winget source..." -ForegroundColor Yellow
    winget source add -n winget -a https://cdn.winget.microsoft.com/cache --accept-source-agreements

    # Add Microsoft Store source using alternative method
    Write-Host "Adding Microsoft Store source..." -ForegroundColor Yellow
    try {
        Invoke-RestMethod -Uri "https://bonguides.com/wsb/msstore" -UseBasicParsing | Invoke-Expression
        Write-Host "Microsoft Store source added successfully." -ForegroundColor Green
    } catch {
        Write-Host "Warning: Could not add Microsoft Store source. Some applications may not be available." -ForegroundColor Yellow
        Write-Host "Error details: $_" -ForegroundColor Yellow
    }

    # Update all sources
    Write-Host "Updating package sources..." -ForegroundColor Yellow
    winget source update

    Write-Host "WinGet installation completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error occurred during WinGet installation: $_" -ForegroundColor Red
    exit 1
} finally {
    # Cleanup any remaining jobs
    Get-Job | Where-Object {$_.State -eq "Running"} | Stop-Job
    Get-Job | Remove-Job
} 