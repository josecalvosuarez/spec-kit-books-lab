<#
  Spec-Driven Development lab - prerequisites check (Windows)
  Run from CMD or PowerShell:
    powershell -ExecutionPolicy Bypass -File scripts\prereqs-check.ps1
  Compatible with Windows PowerShell 5.1 and PowerShell 7+.
#>

$script:failures = 0

function Write-Ok($name, $detail)   { Write-Host ("  [ OK ] {0,-16} {1}" -f $name, $detail) -ForegroundColor Green }
function Write-Bad($name, $detail)  { Write-Host ("  [FAIL] {0,-16} {1}" -f $name, $detail) -ForegroundColor Red; $script:failures++ }
function Write-Warn($name, $detail) { Write-Host ("  [WARN] {0,-16} {1}" -f $name, $detail) -ForegroundColor Yellow }

function Get-VersionFromText($text) {
    $m = [regex]::Match([string]$text, '(\d+)\.(\d+)(\.(\d+))?')
    if ($m.Success) { return [version]("{0}.{1}" -f $m.Groups[1].Value, $m.Groups[2].Value) }
    return $null
}

function Test-Tool($name, $exe, $versionArgs, $minVersion, $hint) {
    $cmd = Get-Command $exe -ErrorAction SilentlyContinue
    if (-not $cmd) { Write-Bad $name "not found. $hint"; return }
    try {
        $out = (& $exe $versionArgs 2>&1 | Out-String).Trim()
    } catch {
        Write-Bad $name "found but failed to run. $hint"; return
    }
    $firstLine = ($out -split "`r?`n")[0]
    if ($minVersion) {
        $v = Get-VersionFromText $out
        if ($v -and $v -lt [version]$minVersion) {
            Write-Bad $name "$firstLine (need $minVersion+). $hint"; return
        }
    }
    Write-Ok $name $firstLine
}

Write-Host ""
Write-Host "Spec-Driven Development lab - prerequisites check" -ForegroundColor Cyan
Write-Host "--------------------------------------------------"

# Python: avoid the Microsoft Store alias, which "exists" but isn't real Python
$py = Get-Command python -ErrorAction SilentlyContinue
if ($py -and $py.Source -like "*WindowsApps*") {
    Write-Bad "python" "points to the Microsoft Store alias. Install Python and disable the alias (see docs\TROUBLESHOOTING.md)."
} else {
    Test-Tool "python" "python" @("--version") "3.11" "winget install --id Python.Python.3.12 -e"
}

Test-Tool "git"     "git"      @("--version") $null  "winget install --id Git.Git -e"
Test-Tool "uv"      "uv"       @("--version") $null  "winget install --id astral-sh.uv -e"
Test-Tool "node"    "node"     @("--version") "20.0" "winget install --id OpenJS.NodeJS.LTS -e"
Test-Tool "npm"     "npm.cmd"  @("--version") $null  "Comes with Node.js."
Test-Tool "gemini"  "gemini"   @("--version") $null  "npm install -g @google/gemini-cli"
Test-Tool "specify" "specify"  @("version")   $null  "uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v1.1.0 ; uv tool update-shell"
Test-Tool "curl"    "curl.exe" @("--version") $null  "Included in Windows 10 1803+. Otherwise: winget install cURL.cURL"

# API key: check it exists without printing it
$key = [Environment]::GetEnvironmentVariable("GEMINI_API_KEY", "Process")
if (-not $key) { $key = [Environment]::GetEnvironmentVariable("GEMINI_API_KEY", "User") }
if ($key) {
    Write-Ok "GEMINI_API_KEY" ("set (" + $key.Substring(0, [Math]::Min(4, $key.Length)) + "...)")
    if (-not [Environment]::GetEnvironmentVariable("GEMINI_API_KEY", "Process")) {
        Write-Warn "GEMINI_API_KEY" "saved, but not loaded in this terminal. Open a new terminal."
    }
} else {
    Write-Bad "GEMINI_API_KEY" "not set. setx GEMINI_API_KEY ""your-key"" and open a new terminal."
}

if ($env:GOOGLE_API_KEY) {
    Write-Warn "GOOGLE_API_KEY" "is also set. Gemini CLI may use it instead of GEMINI_API_KEY."
}

# Execution policy (Spec Kit uses PowerShell scripts)
$policy = Get-ExecutionPolicy -Scope CurrentUser
if ($policy -in @("Restricted", "Undefined", "AllSigned")) {
    $effective = Get-ExecutionPolicy
    if ($effective -in @("Restricted", "AllSigned")) {
        Write-Bad "ExecPolicy" "$effective. Run: powershell -Command ""Set-ExecutionPolicy -Scope CurrentUser RemoteSigned"""
    } else {
        Write-Ok "ExecPolicy" "$effective"
    }
} else {
    Write-Ok "ExecPolicy" "$policy (CurrentUser)"
}

Write-Host "--------------------------------------------------"
if ($script:failures -eq 0) {
    Write-Host "All good! You're ready for Part 2 of the README." -ForegroundColor Green
    exit 0
} else {
    Write-Host "$($script:failures) problem(s) found. Fix them, open a NEW terminal and run this again." -ForegroundColor Red
    Write-Host "See docs\TROUBLESHOOTING.md for help."
    exit 1
}
