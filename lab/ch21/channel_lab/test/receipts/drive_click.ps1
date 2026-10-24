Add-Type @"
using System;using System.Runtime.InteropServices;
public class M32 {
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint x, uint y, uint d, UIntPtr e);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern IntPtr FindWindow(string c, string t);
}
"@
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$out = "D:\qiand-life\1-projects\xr-knowledge-suite\code\channel_lab\test\receipts"

function Click([int]$x, [int]$y) {
  [M32]::SetCursorPos($x, $y) | Out-Null
  Start-Sleep -Milliseconds 250
  [M32]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)  # LEFTDOWN
  [M32]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)  # LEFTUP
  Write-Output "CLICK $x,$y"
}

function Snap([string]$name) {
  Start-Sleep -Milliseconds 1200
  $b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
  $bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.CopyFromScreen($b.Location, [System.Drawing.Point]::Empty, $b.Size)
  $bmp.Save("$out\$name", [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Output "SNAP $name"
}

$h = [M32]::FindWindow($null, "channel_lab")
Write-Output "HWND=$h"
[M32]::SetForegroundWindow($h) | Out-Null
Start-Sleep -Milliseconds 600

# 1) 点击「读取电量」按钮（屏幕坐标取自上一张截图：约 650,421）
Click 650 421
Snap "receipt-21-R2-window-zh-missing.png"

# 2) 点击 English 切英文（约 650,470）
Click 650 470
Snap "receipt-21-T05-window-en.png"

# 3) 点击 中文 切回中文（同位置）
Click 650 470
Snap "receipt-21-T05-window-zh-back.png"
Write-Output "DONE"
