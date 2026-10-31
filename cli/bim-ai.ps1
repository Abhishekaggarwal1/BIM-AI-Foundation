<#
.SYNOPSIS
    BIM-AI-Foundation CLI tool for managing AI rules, skills, and scaffolding Revit plugins.
.DESCRIPTION
    Commands:
      status   - Displays the current configuration, installed skills, and version matrix.
      init     - Installs BIM-AI-Foundation rules and skills into an existing repository.
      new      - Scaffolds a new multi-targeted Revit plugin project ready with AI rules.
      validate - Scans C# files for common Revit API failure modes (STA thread violations, obsolete ElementId, etc.).
      sync     - Synchronizes rules across Cursor, Claude Code, and Copilot.
.EXAMPLE
    pwsh ./cli/bim-ai.ps1 status
    pwsh ./cli/bim-ai.ps1 init -TargetDir "C:\MyRevitPlugin"
    pwsh ./cli/bim-ai.ps1 new -Name "SmartClashDetector" -TargetDir "C:\Projects"
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet("status", "init", "new", "validate", "sync", "help")]
    [string]$Command = "status",

    [Parameter()]
    [string]$Name = "MyRevitPlugin",

    [Parameter()]
    [string]$TargetDir = (Get-Location).Path,

    [Parameter()]
    [string]$RevitVersions = "2024,2025,2026"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

function Show-Header {
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "  BIM-AI-Foundation CLI v1.0.0" -ForegroundColor Cyan
    Write-Host "  AI-Assisted BIM Software Engineering Framework" -ForegroundColor DarkCyan
    Write-Host "==========================================================" -ForegroundColor Cyan
}

function Show-Status {
    Show-Header
    Write-Host "[+] Repository Root: $RepoRoot" -ForegroundColor Green
    
    $skills = Get-ChildItem -Path "$RepoRoot\skills" -Directory -ErrorAction SilentlyContinue
    Write-Host "[+] Available AI Skills ($($skills.Count)):" -ForegroundColor Yellow
    foreach ($skill in $skills) {
        Write-Host "    - $($skill.Name)" -ForegroundColor Gray
    }

    Write-Host "[+] Multi-AI Config Anchors:" -ForegroundColor Yellow
    Write-Host "    - AGENTS.md (AAIF Open Standard)" -ForegroundColor Gray
    Write-Host "    - CLAUDE.md (Claude Code)" -ForegroundColor Gray
    Write-Host "    - .cursor/rules/*.mdc (Cursor Modular Rules)" -ForegroundColor Gray
    Write-Host "    - .github/copilot-instructions.md (GitHub Copilot)" -ForegroundColor Gray
    Write-Host "    - .windsurfrules (Windsurf IDE)" -ForegroundColor Gray
    Write-Host "[+] Supported Revit Versions: 2024 (.NET 4.8), 2025 (.NET 8.0), 2026 (.NET 8.0)" -ForegroundColor Green
}

function Invoke-Init {
    Show-Header
    Write-Host "[*] Initializing BIM-AI-Foundation in: $TargetDir" -ForegroundColor Cyan

    # Copy AI instructions
    Copy-Item "$RepoRoot\AGENTS.md" -Destination "$TargetDir\AGENTS.md" -Force
    Copy-Item "$RepoRoot\CLAUDE.md" -Destination "$TargetDir\CLAUDE.md" -Force
    Copy-Item "$RepoRoot\.cursorrules" -Destination "$TargetDir\.cursorrules" -Force
    Copy-Item "$RepoRoot\.windsurfrules" -Destination "$TargetDir\.windsurfrules" -Force

    # Copy .cursor rules
    $cursorDest = "$TargetDir\.cursor\rules"
    if (-not (Test-Path $cursorDest)) { New-Item -ItemType Directory -Path $cursorDest -Force | Out-Null }
    Copy-Item "$RepoRoot\.cursor\rules\*" -Destination $cursorDest -Recurse -Force

    # Copy Copilot instructions
    $githubDest = "$TargetDir\.github"
    if (-not (Test-Path $githubDest)) { New-Item -ItemType Directory -Path $githubDest -Force | Out-Null }
    Copy-Item "$RepoRoot\.github\copilot-instructions.md" -Destination "$githubDest\copilot-instructions.md" -Force

    # Copy Skills & Knowledge
    Copy-Item "$RepoRoot\skills" -Destination "$TargetDir" -Recurse -Force
    Copy-Item "$RepoRoot\knowledge" -Destination "$TargetDir" -Recurse -Force

    Write-Host "[OK] BIM-AI-Foundation successfully installed into $TargetDir!" -ForegroundColor Green
    Write-Host "    AI coding assistants (Claude Code, Cursor, Copilot) will now automatically use Revit rules." -ForegroundColor White
}

function Invoke-New {
    Show-Header
    $dest = Join-Path $TargetDir $Name
    Write-Host "[*] Scaffolding new Revit Add-in '$Name' in: $dest" -ForegroundColor Cyan

    if (Test-Path $dest) {
        Write-Error "Destination directory '$dest' already exists!"
        return
    }

    # Copy template
    $templatePath = "$RepoRoot\templates\CleanRevitAddin"
    Copy-Item $templatePath -Destination $dest -Recurse -Force

    # Rename Solution and Project files
    Rename-Item "$dest\CleanRevitAddin.sln" "$Name.sln"
    Rename-Item "$dest\src\CleanRevitAddin\CleanRevitAddin.csproj" "$Name.csproj"
    Rename-Item "$dest\src\CleanRevitAddin\CleanRevitAddin.addin" "$Name.addin"
    Rename-Item "$dest\src\CleanRevitAddin" "$Name"

    # Replace namespace and project names in files
    Get-ChildItem -Path $dest -Recurse -Include *.cs, *.xaml, *.csproj, *.addin, *.sln | ForEach-Object {
        (Get-Content $_.FullName) -replace 'CleanRevitAddin', $Name | Set-Content $_.FullName
    }

    # Inject AI Foundation rules into project
    & $PSCommandPath init -TargetDir $dest

    Write-Host "[OK] Plugin '$Name' scaffolded successfully!" -ForegroundColor Green
    Write-Host "    Open '$dest\$Name.sln' in Visual Studio or open the folder in Cursor / VS Code." -ForegroundColor White
}

function Invoke-Validate {
    Show-Header
    Write-Host "[*] Scanning C# files in $TargetDir for Revit API anti-patterns..." -ForegroundColor Cyan

    $csFiles = Get-ChildItem -Path $TargetDir -Recurse -Filter *.cs -ErrorAction SilentlyContinue
    $issuesFound = 0

    foreach ($file in $csFiles) {
        $content = Get-Content $file.FullName
        $lineNum = 0

        foreach ($line in $content) {
            $lineNum++

            # Check 1: ElementId.IntegerValue
            if ($line -match '\.IntegerValue') {
                Write-Host "  [WARN] $($file.Name):$($lineNum) uses obsolete 'ElementId.IntegerValue'. Use 'ElementId.Value' (long) instead." -ForegroundColor Yellow
                $issuesFound++
            }

            # Check 2: Obsolete ParameterType
            if ($line -match 'ParameterType\.') {
                Write-Host "  [WARN] $($file.Name):$($lineNum) uses obsolete 'ParameterType'. Use 'ForgeTypeId' and 'SpecTypeId' instead." -ForegroundColor Yellow
                $issuesFound++
            }

            # Check 3: Obsolete DisplayUnitType
            if ($line -match 'DisplayUnitType\.') {
                Write-Host "  [WARN] $($file.Name):$($lineNum) uses obsolete 'DisplayUnitType'. Use 'UnitTypeId' via UnitUtils instead." -ForegroundColor Yellow
                $issuesFound++
            }

            # Check 4: Unsafe background thread execution
            if ($line -match 'Task\.Run\(' -and $line -match 'doc\.') {
                Write-Host "  [CRITICAL] $($file.Name):$($lineNum) appears to call Revit API inside Task.Run(). Use RevitTask.RunAsync() instead!" -ForegroundColor Red
                $issuesFound++
            }
        }
    }

    if ($issuesFound -eq 0) {
        Write-Host "[OK] Validation clean! No common Revit API anti-patterns detected." -ForegroundColor Green
    } else {
        Write-Host "[!] Found $issuesFound potential issues. Review the warnings above." -ForegroundColor Yellow
    }
}

switch ($Command) {
    "status"   { Show-Status }
    "init"     { Invoke-Init }
    "new"      { Invoke-New }
    "validate" { Invoke-Validate }
    "sync"     { Invoke-Init }
    "help"     { Show-Status }
}
