Add-Type @"
using System;using System.Runtime.InteropServices;
public class M33 {
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint x, uint y, uint d, UIntPtr e);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
}
"@
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$out = "D:\qiand-life\1-projects\xr-knowledge-suite\code\channel_lab\test\receipts"

$p = Get-Process channel_lab
$h = $p.MainWindowHandle
[M33]::ShowWindow($h, 9) | Out-Null
[M33]::SetForegroundWindow($h) | Out-Null
Start-Sleep -Milliseconds 900
$fg = [M33]::GetForegroundWindow()
Write-Output "HWND=$h FOREGROUND=$fg match=$($fg -eq $h)"
if ($fg -ne $h) { Write-Output "ABORT: foreground is not channel_lab"; exit 1 }

$r = New-Object M33+RECT
[M33]::GetWindowRect($h, [ref]$r) | Out-Null
$w = $r.R - $r.L; $ht = $r.B - $r.T
Write-Output "RECT L=$($r.L) T=$($r.T) W=$w H=$ht"
$cx = $r.L + [int]($w/2)
$btn1y = $r.T + [int]($ht*0.578)
$btn2y = $r.T + [int]($ht*0.661)

function Click([int]$x, [int]$y) {
  [M33]::SetCursorPos($x, $y) | Out-Null
  Start-Sleep -Milliseconds 250
  [M33]::mouse_event(2,0,0,0,[UIntPtr]::Zero); [M33]::mouse_event(4,0,0,0,[UIntPtr]::Zero)
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

Click $cx $btn1y
Snap "receipt-21-R2-window-zh-missing.png"
Click $cx $btn2y
Snap "receipt-21-T05-window-en.png"
Click $cx $btn2y
Snap "receipt-21-T05-window-zh-back.png"
Write-Output "DONE"
