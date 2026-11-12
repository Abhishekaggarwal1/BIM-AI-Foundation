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
    [ValidateSet("csharp", "pyrevit", "dynamo", "autocad", "navisworks", "openbim")]
    [string]$Type = "csharp",

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

    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

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

    if (Test-Path $dest) {
        Write-Error "Destination directory '$dest' already exists!"
        return
    }

    if ($Type -eq "pyrevit") {
        Write-Host "[*] Scaffolding new pyRevit Extension '$Name' in: $dest" -ForegroundColor Cyan
        $templatePath = "$RepoRoot\templates\pyRevitExtension"
        Copy-Item $templatePath -Destination $dest -Recurse -Force

        # Rename Extension folder and Tab folder
        $extFolder = Join-Path $dest "MyExtension.extension"
        $newExtFolder = Join-Path $dest "$Name.extension"
        if (Test-Path $extFolder) {
            Rename-Item $extFolder $newExtFolder
            $tabFolder = Join-Path $newExtFolder "MyExtension.tab"
            $newTabFolder = Join-Path $newExtFolder "$Name.tab"
            if (Test-Path $tabFolder) {
                Rename-Item $tabFolder $newTabFolder
            }
        }

        # Inject AI Foundation rules into project
        & $PSCommandPath init -TargetDir $dest

        Write-Host "[OK] pyRevit Extension '$Name.extension' scaffolded successfully!" -ForegroundColor Green
        Write-Host "    Tab: $Name.tab" -ForegroundColor White
        Write-Host "    Panels: Automation.panel (ModelAudit, WallJoiner)" -ForegroundColor White
        Write-Host "    Ready to test in pyRevit! Place in %APPDATA%\pyRevit\Extensions\ or use 'pyrevit extend ui'." -ForegroundColor Yellow
        return
    }

    if ($Type -eq "dynamo") {
        Write-Host "[*] Scaffolding new Dynamo Scripts workspace '$Name' in: $dest" -ForegroundColor Cyan
        $templatePath = "$RepoRoot\templates\DynamoScripts"
        Copy-Item $templatePath -Destination $dest -Recurse -Force

        # Inject AI Foundation rules into project
        & $PSCommandPath init -TargetDir $dest

        Write-Host "[OK] Dynamo Scripts workspace '$Name' scaffolded successfully!" -ForegroundColor Green
        Write-Host "    Templates included: StandardDynamoPythonTemplate.py, BatchParameterSetter.py, RoomAuditScript.py" -ForegroundColor White
        Write-Host "    Open '$dest' in Cursor or VS Code and start authoring Dynamo Python nodes." -ForegroundColor White
        return
    }

    if ($Type -eq "autocad") {
        Write-Host "[*] Scaffolding new AutoCAD .NET Add-in '$Name' in: $dest" -ForegroundColor Cyan
        $templatePath = "$RepoRoot\templates\CleanAutoCADAddin"
        Copy-Item $templatePath -Destination $dest -Recurse -Force

        # Rename Solution and Project files
        Rename-Item "$dest\CleanAutoCADAddin.sln" "$Name.sln"
        Rename-Item "$dest\src\CleanAutoCADAddin\CleanAutoCADAddin.csproj" "$Name.csproj"
        Rename-Item "$dest\src\CleanAutoCADAddin" "$Name"

        # Replace namespace and project names in files
        Get-ChildItem -Path $dest -Recurse -Include *.cs, *.csproj, *.xml, *.sln | ForEach-Object {
            (Get-Content $_.FullName) -replace 'CleanAutoCADAddin', $Name | Set-Content $_.FullName
        }

        # Inject AI Foundation rules into project
        & $PSCommandPath init -TargetDir $dest

        Write-Host "[OK] AutoCAD Add-in '$Name' scaffolded successfully!" -ForegroundColor Green
        Write-Host "    Solution: $dest\$Name.sln" -ForegroundColor White
        Write-Host "    Multi-targets: net48 (AutoCAD 2024) and net8.0-windows (AutoCAD 2025/2026)" -ForegroundColor White
        Write-Host "    Commands included: BIM_DRAWGRID, BIM_AUDITLAYERS" -ForegroundColor White
        return
    }

    if ($Type -eq "navisworks") {
        Write-Host "[*] Scaffolding new Navisworks Add-in '$Name' in: $dest" -ForegroundColor Cyan
        $templatePath = "$RepoRoot\templates\CleanNavisworksAddin"
        Copy-Item $templatePath -Destination $dest -Recurse -Force

        # Rename Solution and Project files
        Rename-Item "$dest\CleanNavisworksAddin.sln" "$Name.sln"
        Rename-Item "$dest\src\CleanNavisworksAddin\CleanNavisworksAddin.csproj" "$Name.csproj"
        Rename-Item "$dest\src\CleanNavisworksAddin" "$Name"

        # Replace namespace and project names in files
        Get-ChildItem -Path $dest -Recurse -Include *.cs, *.csproj, *.xml, *.sln | ForEach-Object {
            (Get-Content $_.FullName) -replace 'CleanNavisworksAddin', $Name | Set-Content $_.FullName
        }

        # Inject AI Foundation rules into project
        & $PSCommandPath init -TargetDir $dest

        Write-Host "[OK] Navisworks Add-in '$Name' scaffolded successfully!" -ForegroundColor Green
        Write-Host "    Solution: $dest\$Name.sln" -ForegroundColor White
        Write-Host "    Project: $dest\src\$Name\$Name.csproj" -ForegroundColor White
        Write-Host "    Ready for Clash Detective automation and custom plugins." -ForegroundColor White
        return
    }

    if ($Type -eq "openbim") {
        Write-Host "[*] Scaffolding new OpenBIM IFC Tools workspace '$Name' in: $dest" -ForegroundColor Cyan
        $templatePath = "$RepoRoot\templates\OpenBimIfcTools"
        Copy-Item $templatePath -Destination $dest -Recurse -Force

        # Inject AI Foundation rules into project
        & $PSCommandPath init -TargetDir $dest

        Write-Host "[OK] OpenBIM IFC Tools workspace '$Name' scaffolded successfully!" -ForegroundColor Green
        Write-Host "    Scripts included: audit_ifc_properties.py" -ForegroundColor White
        Write-Host "    Ready for IfcOpenShell and buildingSMART IDS automation." -ForegroundColor White
        return
    }

    Write-Host "[*] Scaffolding new Revit Add-in '$Name' in: $dest" -ForegroundColor Cyan

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
    Write-Host "[*] Scanning C# and Python files in $TargetDir for Revit API anti-patterns..." -ForegroundColor Cyan

    $codeFiles = Get-ChildItem -Path $TargetDir -Recurse -Include *.cs, *.py -ErrorAction SilentlyContinue
    $issuesFound = 0

    foreach ($file in $codeFiles) {
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

            # Check 4: Unsafe background thread execution (C# specific)
            if ($file.Extension -eq ".cs" -and $line -match 'Task\.Run\(' -and $line -match 'doc\.') {
                Write-Host "  [CRITICAL] $($file.Name):$($lineNum) appears to call Revit API inside Task.Run(). Use RevitTask.RunAsync() instead!" -ForegroundColor Red
                $issuesFound++
            }

            # Check 5: Dynamo TransactionManager violation
            if ($file.FullName -match 'Dynamo' -and $line -match 'new Transaction\(') {
                Write-Host "  [WARN] $($file.Name):$($lineNum) uses raw 'Transaction'. In Dynamo Python, use 'TransactionManager.Instance.EnsureInTransaction(doc)'." -ForegroundColor Yellow
                $issuesFound++
            }

            # Check 6: AutoCAD STA threading violation
            if ($file.Extension -eq ".cs" -and $line -match 'Task\.Run\(' -and $line -match 'db\.TransactionManager') {
                Write-Host "  [CRITICAL] $($file.Name):$($lineNum) calls AutoCAD TransactionManager inside Task.Run(). AutoCAD requires STA and DocumentLock!" -ForegroundColor Red
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
