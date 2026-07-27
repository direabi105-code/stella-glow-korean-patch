param(
    [string]$PackageRoot = $PSScriptRoot
)
$ErrorActionPreference = 'Stop'
$manifestPath = Join-Path $PackageRoot 'metadata\patch_manifest_v31.json'
$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
$titleRoot = Join-Path $PackageRoot 'luma\titles\0004000000173700'
$romfs = Join-Path $titleRoot 'romfs'
$failed = New-Object System.Collections.Generic.List[string]
$expectedPaths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
foreach ($entry in $manifest.files) {
    [void]$expectedPaths.Add([string]$entry.path)
}
$actualPaths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
foreach ($item in Get-ChildItem -LiteralPath $romfs -Recurse -File) {
    $relative = $item.FullName.Substring($romfs.Length + 1).Replace('\', '/')
    [void]$actualPaths.Add($relative)
    if (-not $expectedPaths.Contains($relative)) {
        $failed.Add("UNLISTED $relative")
    }
}
if ($actualPaths.Count -ne [int]$manifest.changed_file_count) {
    $failed.Add("COUNT manifest=$($manifest.changed_file_count) actual=$($actualPaths.Count)")
}
foreach ($entry in $manifest.files) {
    $path = Join-Path $romfs ($entry.path -replace '/', '\')
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $failed.Add("MISSING $($entry.path)")
        continue
    }
    $item = Get-Item -LiteralPath $path
    if ($item.Length -ne [int64]$entry.patched_bytes) {
        $failed.Add("SIZE $($entry.path)")
        continue
    }
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash
    if ($hash -ne $entry.patched_sha256) {
        $failed.Add("HASH $($entry.path)")
    }
}
foreach ($entry in $manifest.extras) {
    $path = Join-Path $titleRoot ($entry.path -replace '/', '\')
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $failed.Add("MISSING $($entry.path)")
        continue
    }
    $item = Get-Item -LiteralPath $path
    if ($item.Length -ne [int64]$entry.bytes) {
        $failed.Add("SIZE $($entry.path)")
        continue
    }
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash
    if ($hash -ne $entry.sha256) {
        $failed.Add("HASH $($entry.path)")
    }
}
if ($failed.Count -gt 0) {
    $failed | ForEach-Object { Write-Error $_ }
    throw "Patch verification failed: $($failed.Count) file(s)"
}
Write-Host "PASS: $($manifest.changed_file_count) RomFS + $($manifest.extra_file_count) extra v31 patch files verified."
