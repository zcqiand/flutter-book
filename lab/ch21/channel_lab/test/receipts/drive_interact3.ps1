Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$out = "D:\qiand-life\1-projects\xr-knowledge-suite\code\channel_lab\test\receipts"

$p = Get-Process -Id 29068
$h = $p.MainWindowHandle
Write-Output "HWND=$h"
Add-Type @"
using System;using System.Runtime.InteropServices;
public class W32 {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);
  [DllImport("user32.dll")] public static extern bool SetFocus(IntPtr h);
}
"@
[W32]::ShowWindow($h, 9) | Out-Null
[W32]::SetForegroundWindow($h) | Out-Null
Start-Sleep -Milliseconds 700
$fg = [System.Windows.Forms.Form]::ActiveForm
Write-Output "FOREGROUND-attempt done"

# SPACE 触发电量读取
[System.Windows.Forms.SendKeys]::SendWait(' ')
Write-Output "SENT SPACE"
Start-Sleep -Milliseconds 1500

# 截图整屏
try {
  $b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
  $bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.CopyFromScreen($b.Location, [System.Drawing.Point]::Empty, $b.Size)
  $bmp.Save("$out\receipt-21-R2-window-zh-missing.png", [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Output "SNAP ok zh"
} catch { Write-Output "SNAP FAIL: $_" }

# Tab + SPACE 切英文
[System.Windows.Forms.SendKeys]::SendWait('{TAB}')
Start-Sleep -Milliseconds 400
[System.Windows.Forms.SendKeys]::SendWait(' ')
Start-Sleep -Milliseconds 1500
try {
  $b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
  $bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.CopyFromScreen($b.Location, [System.Drawing.Point]::Empty, $b.Size)
  $bmp.Save("$out\receipt-21-T05-window-en.png", [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Output "SNAP ok en"
} catch { Write-Output "SNAP FAIL: $_" }
Write-Output "DONE"
