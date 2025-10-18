# Organize Desktop (PowerShell)

Keep your Windows desktop tidy with a single hotkey. This script groups loose files and folders into two desktop folders, keeping app shortcuts in place so you don’t lose quick access.

## What It Does

- Creates `Loose Files` and `Loose Media` on your Desktop (if missing).
- Moves all files from the Desktop into one of those folders:
  - Media files go to `Loose Media` (jpg, png, gif, bmp, mp4, mov, avi, mp3, wav).
  - Everything else goes to `Loose Files`.
- Skips `.lnk` shortcuts that point to `.exe` apps so your app shortcuts stay on the Desktop.
- Moves all Desktop folders into `Loose Files` (except `Loose Files` and `Loose Media`).
- Prints a log of actions and, when run directly, waits for Enter to close.

Script: `Organize-Desktop.ps1`

## How It Works

- Determines your Desktop path and ensures the two target folders exist.
- For each file on the Desktop:
  - If it’s a `.lnk` and points to an `.exe`, it’s skipped.
  - Otherwise, it is moved to `Loose Media` if the extension matches a media list; else to `Loose Files`.
- For each folder on the Desktop (excluding the two target folders), move it to `Loose Files`.

Note on name conflicts: if a file/folder with the same name already exists in the destination, the move may fail; the script logs the error but continues.

## Requirements

- Windows 10/11
- PowerShell 5.1+ (or PowerShell 7+ on Windows)
- Default Windows COM components (used to read `.lnk` targets)

## Run It

From PowerShell:

```powershell
# Navigate to the script folder, then:
./Organize-Desktop.ps1
```

If your execution policy blocks the script, either run it with a bypass:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\<you>\Scripts\Organize-Desktop\Organize-Desktop.ps1"
```

Or set a safer per-user policy once:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

## Assign a Global Hotkey (Windows)

Windows supports global hotkeys via shortcuts. Create a shortcut that launches PowerShell with this script, then assign a key combo.

1) Create the shortcut
- Right-click Desktop → New → Shortcut.
- For the Target, use:
  
  ```
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\<you>\Scripts\Organize-Desktop\Organize-Desktop.ps1"
  ```
- Name it e.g. `Organize Desktop` and click Finish.

2) Make the hotkey global
- Move the shortcut into your Start Menu Programs folder so the hotkey works even when Desktop is not focused:
  - Press Win+R → paste: `%AppData%\Microsoft\Windows\Start Menu\Programs` → OK.
  - Move the `Organize Desktop` shortcut into that folder.

3) Assign the hotkey
- Right-click the shortcut → Properties → Shortcut tab.
- Click the `Shortcut key` box and press your combo (Windows adds `Ctrl+Alt+` automatically). Example: press `O` to get `Ctrl+Alt+O`.
- Optional: set `Run` to `Minimized` so the console doesn’t grab focus.
- Click OK.

Now pressing your chosen hotkey runs the organizer.

Notes:
- Because the script ends with a “Press Enter to close” prompt, a console window will appear. If you prefer it to close automatically when launched by hotkey, remove the final `Read-Host` line or add a parameter to skip the pause and update the shortcut accordingly.
- Global hotkeys work for shortcuts located on the Desktop or in the Start Menu Programs folder. Taskbar-pinned items do not support the `Shortcut key` property.

### Optional: Create the Shortcut via PowerShell (with Hotkey)

You can create the Start Menu shortcut and assign a hotkey in one go:

```powershell
$script   = "C:\\Users\\<you>\\Scripts\\Organize-Desktop\\Organize-Desktop.ps1"
$target   = "powershell.exe"
$args     = "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
$startDir = Split-Path $script
$destDir  = Join-Path $env:APPDATA 'Microsoft\\Windows\\Start Menu\\Programs'
$destLnk  = Join-Path $destDir 'Organize Desktop.lnk'

$shell = New-Object -ComObject WScript.Shell
$lnk = $shell.CreateShortcut($destLnk)
$lnk.TargetPath  = $target
$lnk.Arguments   = $args
$lnk.WorkingDirectory = $startDir
$lnk.WindowStyle = 7 # Minimized
$lnk.Hotkey      = 'CTRL+ALT+O'
$lnk.IconLocation = '%SystemRoot%\\System32\\shell32.dll,44'
$lnk.Save()
"Created: $destLnk"
```

Adjust `Hotkey` if you want a different combo.

## Customize Media Types

Edit the media extensions list near the top of the script to control what goes into `Loose Media`:

```powershell
$mediaExtensions = @('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.mp4', '.mov', '.avi', '.mp3', '.wav')
```

Add or remove extensions as needed (use lower-case, include the dot).

## Troubleshooting

- “This file came from another computer…” warnings: run `Unblock-File ./Organize-Desktop.ps1` once.
- Execution policy errors: see the Run It section for `-ExecutionPolicy Bypass` or setting per-user policy.
- Conflicting names in destination: the script logs the error and continues. Rename the item and re-run.
- Shortcut hotkey doesn’t trigger: ensure the shortcut is on Desktop or in `%AppData%\Microsoft\Windows\Start Menu\Programs`.
- Odd arrow characters in output: harmless console encoding; does not affect moves.

## Safety

- Only files and folders on your Desktop are moved.
- App shortcuts (`.lnk` → `.exe`) stay on the Desktop.
- No deletions; everything is moved into `Loose Files` or `Loose Media`.
