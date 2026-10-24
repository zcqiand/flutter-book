# ascii-only: click button then back within 3s
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class RC {
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint dx, uint dy, int d, UIntPtr e);
}
'@
function ClickAt([int]$x, [int]$y) {
  [RC]::SetCursorPos($x, $y) | Out-Null
  Start-Sleep -Milliseconds 120
  [RC]::mouse_event(0x02,0,0,0,[UIntPtr]::Zero)
  Start-Sleep -Milliseconds 50
  [RC]::mouse_event(0x04,0,0,0,[UIntPtr]::Zero)
  Write-Output "CLICK $x $y"
}
ClickAt 650 410
Start-Sleep -Milliseconds 800
ClickAt 40 72
