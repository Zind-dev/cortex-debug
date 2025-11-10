# Complete build and package script for cortex-debug
# Rebuilds native modules and creates VSIX package

param(
    [string]$ElectronVersion = "32.2.7"  # VS Code 1.103.1 uses Electron 32
)

Write-Host "`n=== Cortex-Debug Build and Package ===" -ForegroundColor Cyan
Write-Host "Electron Version: $ElectronVersion" -ForegroundColor Cyan

# Step 1: Clean previous builds
Write-Host "`n[1/5] Cleaning previous builds..." -ForegroundColor Yellow
if (Test-Path "dist") {
    Remove-Item -Recurse -Force "dist"
}
if (Test-Path "*.vsix") {
    Remove-Item -Force "*.vsix"
}

# Step 2: Install dependencies
Write-Host "`n[2/5] Installing dependencies..." -ForegroundColor Yellow
npm install

# Step 3: Rebuild native modules for Electron
Write-Host "`n[3/5] Rebuilding native modules for Electron $ElectronVersion..." -ForegroundColor Yellow
if (-not (Test-Path "node_modules\electron-rebuild")) {
    npm install --save-dev electron-rebuild
}
npx electron-rebuild -v $ElectronVersion

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Native module rebuild failed!" -ForegroundColor Red
    exit 1
}

# Step 4: Compile TypeScript
Write-Host "`n[4/5] Compiling TypeScript..." -ForegroundColor Yellow
npm run compile

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Compilation failed!" -ForegroundColor Red
    exit 1
}

# Step 5: Package VSIX
Write-Host "`n[5/5] Creating VSIX package..." -ForegroundColor Yellow
npx vsce package

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== Build Complete! ===" -ForegroundColor Green
    $vsixFile = Get-ChildItem -Filter "*.vsix" | Select-Object -First 1
    if ($vsixFile) {
        Write-Host "VSIX file created: $($vsixFile.Name)" -ForegroundColor Green
        Write-Host "Size: $([math]::Round($vsixFile.Length / 1MB, 2)) MB" -ForegroundColor Green
    }
} else {
    Write-Host "`nError: VSIX packaging failed!" -ForegroundColor Red
    exit 1
}
