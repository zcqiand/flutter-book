# (ascii-only comment)
# (ascii-only comment)
#   powershell -File ps_input.ps1 -Window async_lab -Action ClickCenter
#   powershell -File ps_input.ps1 -Window async_lab -Action ClickBack
#   powershell -File ps_input.ps1 -Window isolate_lab -Action ClickFab
#   powershell -File ps_input.ps1 -Window isolate_lab -Action WheelScroll -Seconds 20
param(
  [string]$Window = "async_lab",
  [string]$Action = "ClickCenter",
  [int]$Seconds = 20,
  [long]$Hwnd = 0
)
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint dwFlags, uint dx, uint dy, int dwData, UIntPtr dwExtraInfo);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr FindWindowW(string cls, string title);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hWnd, out RECT r);
  [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr hWnd, ref POINT p);
  [DllImport("user32.dll")] public static extern uint GetDpiForWindow(IntPtr hWnd);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L; public int T; public int R; public int B; }
  [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X; public int Y; }
}
"@
function Get-Client([IntPtr]$h) {
  $r = New-Object Win32+RECT
  [Win32]::GetClientRect($h, [ref]$r) | Out-Null
  $o = New-Object Win32+POINT
  $o.X = 0; $o.Y = 0
  [Win32]::ClientToScreen($h, [ref]$o) | Out-Null
  $s = [Win32]::GetDpiForWindow($h) / 96.0
  @{ ScreenX = $o.X; ScreenY = $o.Y; W = [int]($r.R - $r.L); H = [int]($r.B - $r.T); Scale = $s }
}
function Click([int]$x, [int]$y) {
  [Win32]::SetCursorPos($x, $y) | Out-Null
  Start-Sleep -Milliseconds 150
  [Win32]::mouse_event(0x02, 0, 0, 0, [UIntPtr]::Zero)
  Start-Sleep -Milliseconds 60
  [Win32]::mouse_event(0x04, 0, 0, 0, [UIntPtr]::Zero)
  Write-Output "CLICK $x $y"
}
if ($Hwnd -gt 0) {
  $hwnd = [IntPtr]$Hwnd
} else {
  $hwnd = [Win32]::FindWindowW($null, $Window)
}
if ($hwnd -eq [IntPtr]::Zero) { Write-Output "WINDOW NOT FOUND: $Window"; exit 1 }
[Win32]::SetForegroundWindow($hwnd) | Out-Null
Start-Sleep -Milliseconds 400
$c = Get-Client $hwnd
Write-Output ("CLIENT {0}x{1} scale={2} at({3},{4})" -f $c.W, $c.H, $c.Scale, $c.ScreenX, $c.ScreenY)
switch ($Action) {
  "ClickCenter" {
    Click ($c.ScreenX + [int]($c.W / 2)) ($c.ScreenY + [int]($c.H / 2))
  }
  "ClickBack" {
# (ascii-only comment)
    $x = $c.ScreenX + [int](28 * $c.Scale)
    $y = $c.ScreenY + [int](28 * $c.Scale)
    Click $x $y
  }
  "RaceSequence" {
# (ascii-only comment)
    $x1 = $c.ScreenX + [int]($c.W / 2)
    $y1 = $c.ScreenY + [int]($c.H / 2)
    Write-Output ("RACE-CLICK1 {0} {1}" -f $x1, $y1)
    Click $x1 $y1
    Start-Sleep -Milliseconds 800
    $x2 = $c.ScreenX + [int](28 * $c.Scale)
    $y2 = $c.ScreenY + [int](28 * $c.Scale)
    Write-Output ("RACE-CLICK2 {0} {1}" -f $x2, $y2)
    Click $x2 $y2
  }
  "ClickFab" {
# (ascii-only comment)
    $x = $c.ScreenX + $c.W - [int](90 * $c.Scale)
    $y = $c.ScreenY + $c.H - [int](40 * $c.Scale)
    Click $x $y
  }
  "WheelScroll" {
# (ascii-only comment)
    [Win32]::SetCursorPos($c.ScreenX + [int]($c.W / 2), $c.ScreenY + [int]($c.H / 2)) | Out-Null
    Start-Sleep -Milliseconds 200
    $ticks = $Seconds * 10
    for ($i = 0; $i -lt $ticks; $i++) {
      [Win32]::mouse_event(0x0800, 0, 0, -120, [UIntPtr]::Zero)
      Start-Sleep -Milliseconds 100
    }
    Write-Output "WHEEL DONE ($ticks ticks over $Seconds s)"
  }
  "FabScroll" {
    # ascii-only: click FAB bottom-right, then wheel-scroll center for N seconds
    $fx = $c.ScreenX + $c.W - [int](90 * $c.Scale)
    $fy = $c.ScreenY + $c.H - [int](40 * $c.Scale)
    Click $fx $fy
    [Win32]::SetCursorPos($c.ScreenX + [int]($c.W / 2), $c.ScreenY + [int]($c.H / 2)) | Out-Null
    $ticks = $Seconds * 10
    $i = 0
    while ($i -lt $ticks) {
      [Win32]::mouse_event(0x0800, 0, 0, -120, [UIntPtr]::Zero)
      Start-Sleep -Milliseconds 100
      $i++
    }
    Write-Output "WHEEL DONE ($ticks ticks over $Seconds s)"
  }
}
