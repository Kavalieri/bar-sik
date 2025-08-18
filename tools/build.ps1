# Build script for Bar-Sik - Windows PowerShell version
# Automated builds for Windows and Android

param(
    [Parameter(Position=0)]
    [ValidateSet("build", "windows", "android", "clean", "help")]
    [string]$Command = "build"
)

# Configuration
$ProjectName = "Bar-Sik"
$ProjectPath = ".\project"
$BuildDir = ".\build"
$GodotExecutable = "godot"  # Change this to full path if needed

# Helper functions
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Create build directory
function Setup-BuildDir {
    Write-Status "Setting up build directory..."
    New-Item -ItemType Directory -Force -Path "$BuildDir\windows" | Out-Null
    New-Item -ItemType Directory -Force -Path "$BuildDir\android" | Out-Null
}

# Export for Windows
function Build-Windows {
    Write-Status "Building Windows version..."

    Push-Location $ProjectPath

    try {
        $result = & $GodotExecutable --headless --export-release "Windows Desktop" "..\$BuildDir\windows\$ProjectName.exe"

        if ($LASTEXITCODE -eq 0) {
            Write-Success "Windows build completed!"

            # Create ZIP package
            Push-Location "..\$BuildDir\windows"
            Compress-Archive -Path "$ProjectName.exe" -DestinationPath "$ProjectName-Windows.zip" -Force
            Write-Success "Windows package created: $ProjectName-Windows.zip"
            Pop-Location
        } else {
            Write-Error "Windows build failed!"
            exit 1
        }
    }
    finally {
        Pop-Location
    }
}

# Export for Android
function Build-Android {
    Write-Status "Building Android version..."

    Push-Location $ProjectPath

    try {
        $result = & $GodotExecutable --headless --export-release "Android" "..\$BuildDir\android\$ProjectName.aab"

        if ($LASTEXITCODE -eq 0) {
            Write-Success "Android build completed!"
            Write-Success "Android package created: $ProjectName.aab"
        } else {
            Write-Error "Android build failed!"
            exit 1
        }
    }
    finally {
        Pop-Location
    }
}

# Validate builds
function Validate-Builds {
    Write-Status "Validating builds..."

    # Check Windows build
    $winExe = "$BuildDir\windows\$ProjectName.exe"
    if (Test-Path $winExe) {
        $winSize = (Get-Item $winExe).Length
        Write-Success "Windows executable: $winSize bytes"
    } else {
        Write-Error "Windows executable not found!"
    }

    # Check Android build
    $androidAab = "$BuildDir\android\$ProjectName.aab"
    if (Test-Path $androidAab) {
        $androidSize = (Get-Item $androidAab).Length
        Write-Success "Android bundle: $androidSize bytes"
    } else {
        Write-Error "Android bundle not found!"
    }
}

# Clean build directory
function Clean-BuildDir {
    Write-Status "Cleaning build directory..."
    if (Test-Path $BuildDir) {
        Remove-Item -Recurse -Force $BuildDir
    }
    Write-Success "Build directory cleaned!"
}

# Main build function
function Build-All {
    Write-Status "Starting build process for $ProjectName"

    Setup-BuildDir

    # Check if Godot is available
    try {
        $null = Get-Command $GodotExecutable -ErrorAction Stop
    }
    catch {
        Write-Error "Godot executable '$GodotExecutable' not found!"
        Write-Warning "Make sure Godot is in your PATH or update the `$GodotExecutable variable"
        exit 1
    }

    # Check if project exists
    if (-not (Test-Path "$ProjectPath\project.godot")) {
        Write-Error "Project file not found at $ProjectPath\project.godot"
        exit 1
    }

    Build-Windows
    Build-Android

    Validate-Builds

    Write-Success "All builds completed successfully!"
    Write-Status "Build artifacts are in: $BuildDir"
}

# Help function
function Show-Help {
    Write-Host "Usage: .\build.ps1 [COMMAND]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  build       Build all platforms (default)"
    Write-Host "  windows     Build Windows version only"
    Write-Host "  android     Build Android version only"
    Write-Host "  clean       Clean build directory"
    Write-Host "  help        Show this help message"
    Write-Host ""
    Write-Host "Configuration:"
    Write-Host "  Update `$GodotExecutable variable with path to your Godot installation"
}

# Execute based on command
switch ($Command) {
    "build" {
        Build-All
    }
    "windows" {
        Setup-BuildDir
        Build-Windows
    }
    "android" {
        Setup-BuildDir
        Build-Android
    }
    "clean" {
        Clean-BuildDir
    }
    "help" {
        Show-Help
    }
    default {
        Write-Error "Unknown command: $Command"
        Show-Help
        exit 1
    }
}
