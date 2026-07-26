param(
    [string]$PackageRoot = $PSScriptRoot
)
$ErrorActionPreference = 'Stop'
$manifestPath = Join-Path $PackageRoot 'metadata\patch_manifest_v30.json'
$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
$romfs = Join-Path $PackageRoot 'luma\titles\0004000000173700\romfs'
$failed = New-Object System.Collections.Generic.List[string]
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
if ($failed.Count -gt 0) {
    $failed | ForEach-Object { Write-Error $_ }
    throw "Patch verification failed: $($failed.Count) file(s)"
}
Write-Host "PASS: $($manifest.changed_file_count) v30 patch files verified."
