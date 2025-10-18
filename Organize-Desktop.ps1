# === Organize-Desktop.ps1 ===
# Organize desktop by moving all files and folders (except .lnk to .exe)
# into Loose Files or Loose Media.

$desktop = [Environment]::GetFolderPath("Desktop")
$looseFiles = Join-Path $desktop "Loose Files"
$looseMedia = Join-Path $desktop "Loose Media"

# Ensure folders exist
foreach ($folder in @($looseFiles, $looseMedia)) {
    if (!(Test-Path $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }
}

# Define media extensions
$mediaExtensions = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".mp4", ".mov", ".avi", ".mp3", ".wav")

Write-Host "`n--- Starting desktop cleanup ---`n"

# === Handle FILES ===
Get-ChildItem -Path $desktop -File | ForEach-Object {
    try {
        $file = $_
        $ext = $file.Extension.ToLower()

        # Skip shortcuts to executables
        if ($ext -eq ".lnk") {
            $target = (New-Object -ComObject WScript.Shell).CreateShortcut($file.FullName).TargetPath
            if ($target -match "\.exe$") {
                Write-Host "Skipping executable shortcut: $($file.Name)"
                return
            }
        }

        # Choose destination
        $dest = if ($mediaExtensions -contains $ext) { $looseMedia } else { $looseFiles }

        Move-Item -Path $file.FullName -Destination $dest -Force
        Write-Host "Moved file: $($file.Name) → $dest"
    }
    catch {
        Write-Host "Error moving $($_.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

# === Handle FOLDERS ===
Get-ChildItem -Path $desktop -Directory | ForEach-Object {
    $folder = $_
    if ($folder.Name -in @("Loose Files", "Loose Media")) { return }

    try {
        Move-Item -Path $folder.FullName -Destination $looseFiles -Force
        Write-Host "Moved folder: $($folder.Name) → $looseFiles"
    }
    catch {
        Write-Host "Error moving folder $($folder.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n Cleanup complete. Press Enter to close."
Read-Host | Out-Null
