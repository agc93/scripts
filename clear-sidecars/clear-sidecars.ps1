<#

.SYNOPSIS
Remove unmatched sidecar files from a directory

.DESCRIPTION
Removes sidecar files (i.e. CR2 and other RAW formats) that don't have their matching compressed format (i.e. JPG). Perfect for clearing out RAW files after a "first-pass" cull.
Can also be used in reverse to remove compressed versions of already-removed RAW images.

.PARAMETER WorkingDirectory
The working directory (defaults to current directory)
.PARAMETER Reverse
Use this switch to reverse the default clean direction. By default, we clean CR2s without matching JPGs. Using this switch will instead clean JPGs without matching CR2s.
.PARAMETER Pattern
Use this pattern to restrict the files processed by the script. Defaults any pattern supported by Get-ChildItem's Filter parameter.
.PARAMETER Verbosity
Specifies the amount of information to be displayed
.PARAMETER DryRun
Performs a dry run

.LINK
https://github.com/agc93/scripts

#>

[CmdletBinding()]
Param(
    [string]$WorkingDirectory = $env:PWD,
    [switch]$Reverse,
    [ValidateSet("Quiet", "Normal", "Verbose")]
    [string]$Verbosity = "Normal",
    [Alias("WhatIf", "Noop")]
    [switch]$DryRun,
    [Parameter(Position=1,Mandatory=$false)]
    [string]$Pattern = "*.*"
)

$RawFormats = @(".ari", ".arw", ".bay", ".crw", ".cr2", ".dng", ".eip", ".gpr", ".kdc", ".mdc", ".mrw", ".nef", ".nrw", ".orf", ".pef", ".r3d", ".raf", ".raw", ".rwl", ".rw2", ".sr2", ".srf", ".srw", ".x3f")
$CompressedFormats = @(".jpg")

if ($Verbosity -eq "Verbose") {
    $InformationPreference = "Continue"
    $VerbosePreference = "Continue"
}
if ($Verbosity -eq "Normal") {
    $InformationPreference = "Continue"
}

function Remove-File {
    param($File)
    if ($DryRun.IsPresent) {
        Write-Warning "$File will be deleted!"
    } else {
        Write-Information "Removing $File"
        Remove-Item $File
    }
}
Write-Verbose "Scanning $WorkingDirectory (filtering using $Pattern)"
$AllFiles = Get-ChildItem $WorkingDirectory -Filter $Pattern | Group-Object BaseName
$Length = $AllFiles.Count

Write-Verbose "Matched against $Length file groups..."

foreach ($Group in $AllFiles) {
    if ($Group.Count -ge 2) {
        continue
    }
    Write-Verbose "Processing $($Group.Name)"
    if (($Group.Group[0].Extension -in $RawFormats) -and (!$Reverse.IsPresent)) {
        Remove-File $Group.Group[0].FullName
    }

    if (($Group.Group[0].Extension -in $CompressedFormats) -and ($Reverse.IsPresent)) {
        Remove-File $Group.Group[0].FullName
    }
}