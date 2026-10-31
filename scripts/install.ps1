<#
.SYNOPSIS
    Installs or updates BIM-AI-Foundation in the current or target directory.
.PARAMETER TargetDir
    The target directory where the AI instructions and skills should be installed.
#>

param(
    [string]$TargetDir = (Get-Location).Path
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CliScript = Join-Path (Split-Path -Parent $ScriptDir) "cli\bim-ai.ps1"

& $CliScript init -TargetDir $TargetDir
