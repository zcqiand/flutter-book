Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  [DllImport("user32.dll")] public static extern IntPtr FindWindow(string cls, string title);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
}
"@
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$hwnd = [Win32]::FindWindow($null, "channel_lab")
Write-Output "FINDWINDOW channel_lab => $hwnd"
[Win32]::ShowWindow($hwnd, 9) | Out-Null   # SW_RESTORE
[Win32]::SetForegroundWindow($hwnd) | Out-Null
Start-Sleep -Milliseconds 800
$r = New-Object Win32+RECT
[Win32]::GetWindowRect($hwnd, [ref]$r) | Out-Null
Write-Output "RECT L=$($r.L) T=$($r.T) R=$($r.R) B=$($r.B)"

[System.Windows.Forms.SendKeys]::SendWait(' ')
Write-Output "SENT SPACE"
Start-Sleep -Milliseconds 1200
