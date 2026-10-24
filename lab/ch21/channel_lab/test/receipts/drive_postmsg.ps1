Add-Type @"
using System;using System.Runtime.InteropServices;
public class M34 {
  [DllImport("user32.dll")] public static extern IntPtr FindWindowEx(IntPtr parent, IntPtr after, string cls, string title);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint msg, UIntPtr w, IntPtr l);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
}
"@
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$out = "D:\qiand-life\1-projects\xr-knowledge-suite\code\channel_lab\test\receipts"

$p = Get-Process channel_lab
$main = $p.MainWindowHandle
$child = [M34]::FindWindowEx($main, [IntPtr]::Zero, $null, $null)
Write-Output "MAIN=$main CHILD=$child"
$r = New-Object M34+RECT
[M34]::GetWindowRect($child, [ref]$r) | Out-Null
$w = $r.R - $r.L; $ht = $r.B - $r.T
Write-Output "CHILD RECT L=$($r.L) T=$($r.T) W=$w H=$ht"

function ClickAt([int]$x, [int]$y) {
  $lp = [IntPtr](($y -shl 16) -bor ($x -band 0xFFFF))
  [M34]::PostMessage($child, 0x0201, [UIntPtr]1, $lp) | Out-Null # WM_LBUTTONDOWN
  Start-Sleep -Milliseconds 80
  [M34]::PostMessage($child, 0x0202, [UIntPtr]::Zero, $lp) | Out-Null # WM_LBUTTONUP
  Write-Output "POSTCLICK $x,$y"
}
function Snap([string]$name) {
  Start-Sleep -Milliseconds 1300
  $b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
  $bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.CopyFromScreen($b.Location, [System.Drawing.Point]::Empty, $b.Size)
  $bmp.Save("$out\$name", [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Output "SNAP $name"
}

$cx = [int]($w/2)
ClickAt $cx ([int]($ht*0.554))
Snap "receipt-21-R2-window-zh-missing.png"
ClickAt $cx ([int]($ht*0.627))
Snap "receipt-21-T05-window-en.png"
ClickAt $cx ([int]($ht*0.627))
Snap "receipt-21-T05-window-zh-back.png"
Write-Output "DONE"
