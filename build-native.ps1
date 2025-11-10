# Build script for native modules with Electron compatibility
# This rebuilds usb and serialport for VS Code's Electron version

param(
    [string]$ElectronVersion = "32.2.7"  # VS Code 1.103.1 uses Electron 32
)

Write-Host "Building native modules for Electron $ElectronVersion..." -ForegroundColor Green

# Install dependencies if needed
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
}

# Install electron-rebuild if not present
if (-not (Test-Path "node_modules\electron-rebuild")) {
    Write-Host "Installing electron-rebuild..." -ForegroundColor Yellow
    npm install --save-dev electron-rebuild
}

# Rebuild native modules
Write-Host "Rebuilding native modules (usb, serialport) for Electron $ElectronVersion..." -ForegroundColor Yellow
npx electron-rebuild -v $ElectronVersion

if ($LASTEXITCODE -eq 0) {
    Write-Host "Native modules rebuilt successfully!" -ForegroundColor Green
} else {
    Write-Host "Error rebuilding native modules" -ForegroundColor Red
    exit 1
}
