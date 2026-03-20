$currentDir = Get-Location
$parentDir = Split-Path $currentDir -Parent
$destDir = Join-Path $parentDir "all_reports"

if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir | Out-Null
    Write-Host "Created destination directory: $destDir" -ForegroundColor Cyan
}

$directories = Get-ChildItem -Path $currentDir -Directory | Where-Object { $_.Name -ne "all_reports" }

$count = 0

foreach ($dir in $directories) {
    # Match "doc" or "docs" directories
    $docFolders = Get-ChildItem -Path $dir.FullName -Directory | Where-Object { $_.Name -match "^docs?$" }
    
    foreach ($docFolder in $docFolders) {
        # Find all .md and .pdf files recursively inside the doc/docs folder
        $files = Get-ChildItem -Path $docFolder.FullName -File -Recurse | Where-Object { $_.Extension -match "(?i)\.(md|pdf)$" }
        
        foreach ($file in $files) {
            # Prefix the file name with the student/directory name to prevent duplicate overwrites (like report.md)
            $newName = "{0}_{1}" -f $dir.Name, $file.Name
            $destPath = Join-Path $destDir $newName
            
            Copy-Item -Path $file.FullName -Destination $destPath -Force
            Write-Host "Extracted: $newName"
            $count++
        }
    }
}

Write-Host "`nSuccessfully extracted $count files to: $destDir" -ForegroundColor Green
