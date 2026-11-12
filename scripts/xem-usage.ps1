# In bảng usage của mọi tài khoản, đọc từ usage\tkN.json (do statusline.ps1 ghi).
# Chỉ gợi ý tài khoản còn nhiều nhất; người dùng tự chọn mở tài khoản nào.
param([string]$Chung = '')
try { [Console]::OutputEncoding = New-Object Text.UTF8Encoding $false } catch {}
if (-not $Chung) { $Chung = Split-Path -Parent $PSScriptRoot }
$cfgPath = Join-Path $Chung 'cau-hinh.json'
if (-not (Test-Path $cfgPath)) { Write-Output "Chưa cài. Gõ 'cài nhiều tài khoản' trong Claude Code."; exit 1 }
$cfg = Get-Content $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json
$now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

function Cua($win, $coNgay) {
  # trả về @(chuỗi %, chuỗi reset, % để so sánh)
  if (-not $win -or $null -eq $win.used_percentage) { return @('?', '', 50) }
  if ($win.resets_at -and [int64]$win.resets_at -le $now) { return @('đã reset', '', 0) }
  $d = [DateTimeOffset]::FromUnixTimeSeconds([int64]$win.resets_at).ToLocalTime()
  $r = if ($coNgay) { $d.ToString('dd/MM HH:mm') } else { $d.ToString('HH:mm') }
  return @(('{0:0}%' -f [double]$win.used_percentage), $r, [double]$win.used_percentage)
}
function Truoc($giay) {
  if ($giay -lt 90) { return 'vừa xong' }
  if ($giay -lt 3600) { return ('{0} phút trước' -f [int]($giay / 60)) }
  if ($giay -lt 172800) { return ('{0} giờ trước' -f [int]($giay / 3600)) }
  return ('{0} ngày trước' -f [int]($giay / 86400))
}

$hang = @()
foreach ($tk in $cfg.tai_khoan) {
  $f = Join-Path $Chung ("usage\tk{0}.json" -f $tk.so)
  if (-not (Test-Path $f)) {
    $hang += [pscustomobject]@{ TK = "TK$($tk.so)"; Ten = $tk.ten; G5 = 'chưa có số'; R5 = ''; N7 = ''; R7 = ''; CapNhat = 'chưa mở lần nào'; Diem = 50 }
    continue
  }
  $u = Get-Content $f -Raw -Encoding UTF8 | ConvertFrom-Json
  $a = Cua $u.five_hour $false; $b = Cua $u.seven_day $true
  $hang += [pscustomobject]@{ TK = "TK$($tk.so)"; Ten = $tk.ten; G5 = $a[0]; R5 = $a[1]; N7 = $b[0]; R7 = $b[1]; CapNhat = (Truoc ($now - [int64]$u.cap_nhat)); Diem = [math]::Max([double]$a[2], [double]$b[2]) }
}

Write-Output 'Usage các tài khoản Claude (số chính thức từ Claude Code, chỉ cập nhật khi tài khoản đó đang mở):'
$hang | Format-Table @{ n = 'TK'; e = { $_.TK } }, @{ n = 'Tên'; e = { $_.Ten } }, @{ n = '5 giờ'; e = { $_.G5 } }, @{ n = 'Reset 5h'; e = { $_.R5 } }, @{ n = '7 ngày'; e = { $_.N7 } }, @{ n = 'Reset 7d'; e = { $_.R7 } }, @{ n = 'Cập nhật'; e = { $_.CapNhat } } -AutoSize | Out-String -Width 200 | ForEach-Object { $_.TrimEnd() }
$tot = $hang | Where-Object { $_.G5 -ne 'chưa có số' } | Sort-Object Diem | Select-Object -First 1
if ($tot -and $tot.Diem -lt 90) { Write-Output ("Gợi ý: {0} ({1}) đang còn nhiều nhất." -f $tot.TK, $tot.Ten) }
elseif ($tot) { Write-Output 'Mọi tài khoản đã có số đều từ 90% trở lên. Chờ đến giờ reset.' }
Write-Output "'?' = chưa có số cho khung đó; 'đã reset' = đã qua giờ reset, mở tài khoản đó để cập nhật số mới."
