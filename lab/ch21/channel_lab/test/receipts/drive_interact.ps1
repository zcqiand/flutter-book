# ch21 实测驱动脚本：键盘触发按钮 + 全屏截图（真实抓取，不构造）
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$out = "D:\qiand-life\1-projects\xr-knowledge-suite\code\channel_lab\test\receipts"

function Snap([string]$name) {
  Start-Sleep -Milliseconds 900
  $b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
  $bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.CopyFromScreen($b.Location, [System.Drawing.Point]::Empty, $b.Size)
  $bmp.Save("$out\$name", [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  Write-Output "SNAP $name"
}

$wshell = New-Object -ComObject wscript.shell
$act = $wshell.AppActivate('channel_lab')
Write-Output "ACTIVATE channel_lab => $act"
Start-Sleep -Milliseconds 800

# 1) SPACE 触发「读取电量」（autofocus 在该按钮上）——预期 MissingPluginException
$wshell.SendKeys(' ')
Write-Output "SENT SPACE (read battery)"
Snap "receipt-21-R2-window-zh-missing.png"

# 2) Tab 到语言切换按钮，SPACE 切到英文
$wshell.SendKeys('{TAB}')
Start-Sleep -Milliseconds 300
$wshell.SendKeys(' ')
Write-Output "SENT TAB+SPACE (toggle locale)"
Snap "receipt-21-T05-window-en.png"

# 3) 再按一次 SPACE 切回中文
$wshell.SendKeys(' ')
Write-Output "SENT SPACE (toggle back zh)"
Snap "receipt-21-T05-window-zh-back.png"
Write-Output "DONE"
