Add-Type @'
using System;
using System.Text;
using System.Runtime.InteropServices;
public class WinEnum {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc p, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetWindowTextW(IntPtr h, StringBuilder sb, int max);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int GetClassNameW(IntPtr h, StringBuilder sb, int max);
}
'@
$found = New-Object System.Collections.ArrayList
$cb = [WinEnum+EnumProc]{
  param($h, $l)
  if ([WinEnum]::IsWindowVisible($h)) {
    $sb = New-Object System.Text.StringBuilder 256
    [WinEnum]::GetWindowTextW($h, $sb, 256) | Out-Null
    $title = $sb.ToString()
    $cn = New-Object System.Text.StringBuilder 256
    [WinEnum]::GetClassNameW($h, $cn, 256) | Out-Null
    if ($title.Length -gt 0 -and $cn.ToString() -match 'FLUTTER') {
      $found.Add("hwnd=$h class=$($cn.ToString()) title=[$title]") | Out-Null
    }
  }
  return $true
}
[WinEnum]::EnumWindows($cb, [IntPtr]::Zero) | Out-Null
$found | ForEach-Object { Write-Output $_ }
if ($found.Count -eq 0) { Write-Output 'NO FLUTTER WINDOW' }
