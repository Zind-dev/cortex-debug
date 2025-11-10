# Build and package script using pre-built binaries
# This avoids the need to rebuild native modules

Write-Host "`n=== Cortex-Debug Build and Package (Using Pre-built Binaries) ===" -ForegroundColor Cyan

# Step 1: Clean previous builds
Write-Host "`n[1/4] Cleaning previous builds..." -ForegroundColor Yellow
if (Test-Path "dist") {
    Remove-Item -Recurse -Force "dist"
}
$oldVsix = Get-ChildItem -Filter "*.vsix"
if ($oldVsix) {
    Remove-Item -Force $oldVsix
}

# Step 2: Install dependencies with pre-built binaries
Write-Host "`n[2/4] Installing dependencies..." -ForegroundColor Yellow
# Force npm to download pre-built binaries
$env:npm_config_build_from_source = "false"
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: npm install failed!" -ForegroundColor Red
    exit 1
}

# Step 3: Compile TypeScript
Write-Host "`n[3/4] Compiling TypeScript..." -ForegroundColor Yellow
npm run compile

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Compilation failed!" -ForegroundColor Red
    exit 1
}

# Step 4: Package VSIX
Write-Host "`n[4/4] Creating VSIX package..." -ForegroundColor Yellow
npx vsce package

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== Build Complete! ===" -ForegroundColor Green
    $vsixFile = Get-ChildItem -Filter "*.vsix" | Select-Object -First 1
    if ($vsixFile) {
        Write-Host "VSIX file created: $($vsixFile.Name)" -ForegroundColor Green
        Write-Host "Size: $([math]::Round($vsixFile.Length / 1MB, 2)) MB" -ForegroundColor Green
        Write-Host "`nTo install: code --install-extension $($vsixFile.Name)" -ForegroundColor Cyan
    }
} else {
    Write-Host "`nError: VSIX packaging failed!" -ForegroundColor Red
    exit 1
}
