# ascii-only: focus + topmost the isolate_lab window by pid
param([int]$TargetPid = 0, [string]$Title = "isolate_lab")
Add-Type @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public class WF {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc p, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowTextW(IntPtr h, StringBuilder sb, int max);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint flags);
  [DllImport("user32.dll")] public static extern void keybd_event(byte k, byte s, uint f, UIntPtr e);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
}
'@
$found = [IntPtr]::Zero
$cb = [WF+EnumProc]{ param($h, $l)
  $p = [uint32]0
  [WF]::GetWindowThreadProcessId($h, [ref]$p) | Out-Null
  if ($TargetPid -gt 0 -and $p -eq $TargetPid) {
    $script:found = $h
    return $false
  }
  return $true
}
[WF]::EnumWindows($cb, [IntPtr]::Zero) | Out-Null
if ($found -eq [IntPtr]::Zero) { Write-Output "NOWINDOW pid=$TargetPid"; exit 1 }
[WF]::ShowWindow($found, 9) | Out-Null   # SW_RESTORE
[WF]::SetWindowPos($found, [IntPtr](-1), 0, 0, 0, 0, 0x0001 -bor 0x0002 -bor 0x0010) | Out-Null # TOPMOST NOSIZE NOMOVE SHOWWINDOW
[WF]::keybd_event(0x12, 0, 0, [UIntPtr]::Zero)
[WF]::SetForegroundWindow($found) | Out-Null
[WF]::keybd_event(0x12, 0, 2, [UIntPtr]::Zero)
Write-Output ("FOCUSED hwnd=" + $found)
