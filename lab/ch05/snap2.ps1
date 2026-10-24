param(
  [string]$OutPath = "D:\qiand-life\1-projects\xr-knowledge-suite\output\xr-know-019\lab\ch05\shot.png",
  [int]$ClickX = -1,
  [int]$ClickY = -1
)
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class W32 {
  [DllImport("user32.dll")] public static extern IntPtr FindWindowW(string cls, string title);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint dx, uint dy, uint d, UIntPtr e);
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr dc, uint flags);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
}
"@
$hwnd = [IntPtr]::Zero
$procs = Get-Process | Where-Object { $_.MainWindowTitle -match 'theme_playground' }
if ($procs) { $hwnd = $procs[0].MainWindowHandle }
if ($hwnd -eq [IntPtr]::Zero) { Write-Output "NOWINDOW"; exit 1 }
[W32]::SetForegroundWindow($hwnd) | Out-Null
Start-Sleep -Milliseconds 300
$r = New-Object W32+RECT
[W32]::GetWindowRect($hwnd, [ref]$r) | Out-Null
$w = $r.R - $r.L; $h = $r.B - $r.T
Write-Output ("RECT {0} {1} {2} {3} (w={4} h={5})" -f $r.L, $r.T, $r.R, $r.B, $w, $h)

if ($ClickX -ge 0) {
  [W32]::SetCursorPos($ClickX, $ClickY) | Out-Null
  Start-Sleep -Milliseconds 150
  [W32]::mouse_event(0x0002,0,0,0,[UIntPtr]::Zero)
  Start-Sleep -Milliseconds 60
  [W32]::mouse_event(0x0004,0,0,0,[UIntPtr]::Zero)
  Write-Output "CLICKED $ClickX $ClickY"
  Start-Sleep -Milliseconds 1000
}

$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$dc = $g.GetHdc()
$ok = [W32]::PrintWindow($hwnd, $dc, 2)  # PW_RENDERFULLCONTENT
$g.ReleaseHdc($dc)
$bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output "PRINTWINDOW=$ok SAVED $OutPath"
