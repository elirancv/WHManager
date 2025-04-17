@echo off
SETLOCAL EnableDelayedExpansion

:: Check for Admin Privileges
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~fnx0' -Verb RunAs"
    exit /b
)

:: Define applications (Grouped for clarity)

:: Essential Software
set apps=^
    Brave.Brave "Brave Browser" ^
    RARLab.WinRAR "WinRAR" ^
    Notepad++.Notepad++ "Notepad++" ^

:: Monitoring Tools
set apps=^
    ALCPU.CoreTemp "Core Temp" ^
    Almico.SpeedFan "SpeedFan " ^

:: Security & VPN
set apps=%apps%^
    IDRIX.VeraCrypt "VeraCrypt" ^
    OpenVPNTechnologies.OpenVPN "OpenVPN" ^
    ShiningLight.OpenSSL.Light "OpenSSL" ^
    ente-io.auth-desktop "Ente Auth" ^

:: Media & Music Tools
set apps=%apps%^
    VideoLAN.VLC "VLC Media Player" ^
    AIMP.AIMP "AIMP Music Player" ^
    PointPlanck.FileBot "FileBot" ^
    FlorianHeidenreich.Mp3tag "Mp3tag" ^
    Gyan.FFmpeg "FFmpeg" ^
    vividos.winLAME "winLAME" ^
    MediaArea.MediaInfo.GUI "MediaInfo (GUI)" ^
    MediaArea.MediaInfo "MediaInfo (CLI)" ^

:: Development & Command-Line Tools
set apps=%apps%^
    Microsoft.WindowsTerminal "Windows Terminal" ^
    Microsoft.PowerShell "PowerShell" ^
    Python.Python.3.13 "Python 3.13" ^
    Anaconda.Anaconda3 "Anaconda3" ^
    Git.Git "Git" ^
    Microsoft.VisualStudioCode "VS Code" ^
    GitHub.GitHubDesktop "GitHub Desktop" ^
    ActiveDatabaseSoftware.FlySpeedSQLQuery "FlySpeed SQL Query" ^
    cURL.cURL "cURL" ^
    HermannSchinagl.LinkShellExtension "Link Shell Extension" ^

:: AI Tools
set apps=%apps%^
    Anysphere.Cursor "Cursor Editor" ^
    lencx.ChatGPT "ChatGPT Desktop Application" ^

:: File Management & System Utilities
set apps=%apps%^
    voidtools.Everything "Everything Search" ^
    voidtools.Everything.Cli "Everything CLI" ^
    Wox.Wox "Wox" ^
    PuTTY.PuTTY "PuTTY" ^
    TTYPlus.MTPutty "MTPuTTY" ^
    OpenSight.FlashFXP "FlashFXP" ^
    Glarysoft.GlaryUtilities "Glary Utilities" ^
    Nextcloud.NextcloudDesktop "Nextcloud Desktop Client" ^

:: Dependencies
set apps=%apps%^
    Microsoft.VCRedist.2010.x64 "VC Redist 2010 (x64)" ^
    Microsoft.VCRedist.2010.x86 "VC Redist 2010 (x86)" ^

:: Communication
set apps=%apps%^
    mIRC.mIRC "mIRC" ^
    Telegram.TelegramDesktop "Telegram" ^

:: Log file
set logFile=%USERPROFILE%\winget_install.log
echo Installing applications... > "%logFile%"

:: Install each app
for %%A in (%apps%) do (
    set "id=%%A"
    set /p "name="
    
    echo Checking for !name!...
    winget list --id !id! >nul 2>&1
    if !ERRORLEVEL! NEQ 0 (
        echo Installing !name!...
        winget install --id=!id! -e -h >> "%logFile%" 2>&1
        if !ERRORLEVEL! NEQ 0 (
            echo [ERROR] !name! failed to install! See log for details.
        ) else (
            echo [SUCCESS] !name! installed successfully.
        )
    ) else (
        echo [SKIPPED] !name! is already installed.
    )
)

echo Installation complete! Check "%logFile%" for details.
pause
